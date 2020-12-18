//
//  RepositoriesAPIController.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 18.12.20.
//

import Combine

protocol RepositoriesAPIControllerProtocol: class {
    var networkController: NetworkServiceProtocol { get }
    
    func getBranchDetails(
        repository: String,
        username: String,
        branch: String
    ) -> AnyPublisher<VersionControlBranch, Error>
    
    func getTree(
        repository: String,
        username: String,
        treeSHA: String
    ) -> AnyPublisher<VersionControlTree, Error>
}

final class RepositoriesAPIController: RepositoriesAPIControllerProtocol {
    let networkController: NetworkServiceProtocol
    
    init(networkController: NetworkServiceProtocol) {
        self.networkController = networkController
    }
    
    func getBranchDetails(
        repository: String,
        username: String,
        branch: String
    ) -> AnyPublisher<VersionControlBranch, Error> {
        let endpoint = Endpoint.branchDetails(
            repository: repository,
            username: username,
            branch: branch
        )
        
        return networkController.get(
            type: VersionControlBranch.self,
            url: endpoint.url,
            headers: endpoint.headers
        )
    }
    
    func getTree(
        repository: String,
        username: String,
        treeSHA: String
    ) -> AnyPublisher<VersionControlTree, Error> {
        let endpoint = Endpoint.trees(
            repository: repository,
            username: username,
            treeSHA: treeSHA
        )
        
        return networkController.get(
            type: VersionControlTree.self,
            url: endpoint.url,
            headers: endpoint.headers
        )
    }
}
