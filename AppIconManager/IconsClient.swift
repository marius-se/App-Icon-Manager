//
//  IconsClient.swift
//  AppIconManager
//
//  Created by Marius Seufzer on 22.08.22.
//

import Foundation
import ComposableArchitecture
import AppKit

struct IconsClient {
    enum Failure: Error, Equatable {
        case loadingIconsFailed
    }

    var getIcons: (App) -> Effect<[Icon], Failure>
}

extension IconsClient {
    static var dev: Self {
        .init(
            getIcons: { _ in
                Effect(
                    value: [
                        .init(
                            id: 0,
                            fileURL: URL(
                                string: "https://media.macosicons.com/parse/files/macOSicons/e660b8d0f53a8ae149b1c1132d5fa7f2_Blender.icns"
                            )!,
                            name: "Blender 1",
                            author: "John Doe",
                            lastModified: Date()
                        ),
                        .init(
                            id: 1,
                            fileURL: URL(
                                string: "https://media.macosicons.com/parse/files/macOSicons/f060ba15c786620d64bf4e869ed23229_Blender.icns"
                            )!,
                            name: "Blender 2",
                            author: "John Doe",
                            lastModified: Date()
                        )
                    ]
                )
            }
        )
    }

//    static func live(urlSession: URLSession) -> Self {
//        .init(
//            getIcons: { app in
//                urlSession.dataTas
//            }
//        )
//    }
}

#if DEBUG
import XCTestDynamicOverlay

extension IconsClient {
    static var unimplemented: Self {
        .init(
            getIcons: XCTUnimplemented("\(Self.self).getAllApps")
        )
    }
}
#endif
