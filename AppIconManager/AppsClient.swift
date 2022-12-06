//
//  ApplicationsClient.swift
//  AppIconManager
//
//  Created by Marius Seufzer on 22.08.22.
//

import Foundation
import ComposableArchitecture
import AppKit

struct AppsClient {
    enum Failure: Error, Equatable {
        case openingApplicationDirectoryFailed
        case gettingListOfApplicationsFailed
        case downloadingIconFailed
        case resettingIconFailed
    }

    var getAllApps: () -> Effect<[App], Failure>
    var setIcon: (App, Icon) -> Effect<NSImage, Failure>
    var resetIcon: (App) -> Effect<Never, Failure>
}

extension AppsClient {
    static var dev: Self {
        .init(
            getAllApps: { Effect(value: []) },
            setIcon: { _, _ in .none },
            resetIcon: { _ in .none }
        )
    }

    static func live(urlSession: URLSession) -> Self {
        .init(
            getAllApps: {
                guard let applicationsFolderURL = FileManager.default.urls(
                    for: .applicationDirectory,
                    in: [.localDomainMask]
                ).first else {
                    return Effect(error: .openingApplicationDirectoryFailed)
                }

                var applicationURLs: [URL] = []
                do {
                    applicationURLs = try FileManager.default.contentsOfDirectory(
                        at: applicationsFolderURL,
                        includingPropertiesForKeys: nil
                    )
                } catch {
                    return Effect(error: .gettingListOfApplicationsFailed)
                }

                let applications = applicationURLs
                    .filter { $0.pathExtension == "app" }
                    .sorted(by: { $0.path < $1.path })
                    .map {
                        App(
                            name: $0.deletingPathExtension().lastPathComponent,
                            path: $0.path,
                            icon: NSWorkspace.shared.icon(forFile: $0.path)
                                .sd_resizedImage(with: CGSize(width: 50, height: 50), scaleMode: .aspectFit)!)
                    }
                return Effect(value: applications)
            },
            setIcon: { app, icon in
                let workspace = NSWorkspace.shared
                return urlSession
                    .dataTaskPublisher(for: icon.fileURL)
                    .map(\.data)
                    .tryMap { data -> NSImage in
                        let iconsDirectory = FileManager.default.urls(
                            for: .applicationSupportDirectory,
                            in: .userDomainMask
                        ).first!
                        .appendingPathComponent("AppIconManager")
                        .appendingPathComponent("icons")

                        var isDirectory: ObjCBool = false
                        if !FileManager.default.fileExists(atPath: iconsDirectory.path, isDirectory: &isDirectory) {
                            try FileManager.default.createDirectory(
                                atPath: iconsDirectory.path,
                                withIntermediateDirectories: false
                            )
                        }

                        let fileURL = iconsDirectory
                            .appendingPathComponent(icon.name)
                            .appendingPathExtension("icns")

                        try data.write(to: fileURL)

                        workspace.setIcon(NSImage(contentsOfFile: fileURL.path), forFile: app.path)
                        
                        return workspace.icon(forFile: fileURL.path).sd_resizedImage(with: CGSize(width: 50, height: 50), scaleMode: .aspectFit)!
                    }
                    .mapError { _ in Failure.downloadingIconFailed }
                    .eraseToEffect()
            },
            resetIcon: { app in
                .fireAndForget {
                    NSWorkspace.shared.setIcon(nil, forFile: app.path)
                }
            }
        )
    }
}

#if DEBUG
import XCTestDynamicOverlay

extension AppsClient {
    static var unimplemented: Self {
        .init(
            getAllApps: XCTUnimplemented("\(Self.self).getAllApps"),
            setIcon: XCTUnimplemented("\(Self.self).setIcon"),
            resetIcon: XCTUnimplemented("\(Self.self).resetIcon")
        )
    }
}
#endif
