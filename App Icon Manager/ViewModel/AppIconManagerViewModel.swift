//
//  AppIconManagerViewModel.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 17.12.20.
//

import Foundation

class AppIconManagerViewModel: ObservableObject {
    enum State {
        case idle, loading, error(message: String)
    }
    // MARK: - Properties
    @Published var applications: [Application] = []
    @Published var state: State = .idle
    
    // MARK: - Class methods
    func rereadApplications() {
        state = .loading
        guard let applicationsFolderURL = FileManager.default.urls(
            for: .applicationDirectory,
            in: .localDomainMask
        ).first else {
            state = .error(message: "Couldn't locate application directory")
            return
        }
        
        var applicationURLs: [URL] = []
        do {
            applicationURLs = try FileManager.default.contentsOfDirectory(
                at: applicationsFolderURL,
                includingPropertiesForKeys: nil
            )
        } catch {
            state = .error(message: error.localizedDescription)
        }
        
        applications = applicationURLs
            .filter { $0.pathExtension == "app" }
            .sorted(by: { $0.path < $1.path })
            .map {
                Application(
                    name: $0.deletingPathExtension().lastPathComponent,
                    path: $0.path
                )
            }
        state = .idle
    }
}
