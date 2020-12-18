//
//  IconSelectionViewModel.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 17.12.20.
//

import Foundation
import Combine

class IconSelectionViewModel: ObservableObject {
    enum State {
        case idle, loading, error(message: String)
    }
    // MARK: - Properties
    @Published var icons: [Icon] = []
    @Published var state: State = .idle
    private let application: Application
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(forApplication application: Application) {
        self.application = application
    }
    
    // MARK: - Class methods
    func loadIcons() {
        state = .loading
        
        let networkService = NetworkService()
        let repositoriesAPIController = RepositoriesAPIController(networkController: networkService)
        let repository = "macOS_Big_Sur_icons_replacements"
        let user = "elrumo"
        
        repositoriesAPIController.getBranchDetails(
            repository: repository,
            username: user,
            branch: "master"
        )
        .flatMap { versionControlBranch in
            return repositoriesAPIController.getTree(
                repository: repository,
                username: user,
                treeSHA: versionControlBranch.commit.sha
            )
        }
        .flatMap { versionControlTree -> AnyPublisher<VersionControlTree, Error> in
            let x = versionControlTree.tree.first { $0.path == "icons" && $0.type == .tree }!
            return repositoriesAPIController.getTree(
                repository: repository,
                username: user,
                treeSHA: x.sha
            )
        }
        .receive(on: DispatchQueue.main)
        .sink { (completion) in
            switch completion {
            case .failure(let error):
                self.state = .error(message: error.localizedDescription)
            case .finished:
                self.state = .idle
            }
        } receiveValue: { [weak self] (iconsDirectory) in
            guard let self = self else { return }
            let iconNames = iconsDirectory.tree
                .map { $0.path }
            self.icons = iconNames
                .filter {
                    $0.replacingOccurrences(of: "_", with: " ")
                        .contains(self.application.name)
                    
                }
                .map { Icon(name: $0, path: "https://raw.githubusercontent.com/elrumo/macOS_Big_Sur_icons_replacements/master/icons/\($0)") }
        }
        .store(in: &cancellables)

    }
}
