//
//  GitHubBranch.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 17.12.20.
//

import Foundation
import Combine

struct GitHubBranch: Decodable {
    struct Commit: Decodable {
        let sha: String
    }
    let commit: Commit
}

struct Endpoint {
    var path: String
    
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        
        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        
        return url
    }
    
    var headers: [String: Any] {
        return [:]
    }
}

extension Endpoint {
    static func branchDetails(
        repository: String,
        fromUser username: String,
        onBranch branch: String
    ) -> Self {
        return Endpoint(
            path: "/repos/\(username)/\(repository)/branches/\(branch)"
        )
    }
    
    static func trees(
        repository: String,
        fromUser username: String,
        treeSHA: String
    ) -> Self {
        return Endpoint(
            path: "/repos/\(username)/\(repository)/git/trees/\(treeSHA)"
        )
    }
}

protocol NetworkServiceProtocol: class {
    typealias Headers = [String: Any]
    
    func get<T>(
        type: T.Type,
        url: URL,
        headers: Headers
    ) -> AnyPublisher<T, Error> where T: Decodable
}

final class NetworkService: NetworkServiceProtocol {
    func get<T>(
        type: T.Type,
        url: URL,
        headers: Headers
    ) -> AnyPublisher<T, Error> where T : Decodable {
        var urlRequest = URLRequest(url: url)
        headers.forEach { (key, value) in
            if let value = value as? String {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

protocol RepositoriesAPIControllerProtocol: class {
    var networkController: NetworkServiceProtocol { get }
    
    func getBranchDetails(
        ofRepository repository: String,
        fromUser username: String,
        branch: String
    ) -> AnyPublisher<GitHubBranch, Error>
    
    func getTree(
        repository: String,
        fromUser username: String,
        treeSHA: String
    ) -> AnyPublisher<VersionControlTree, Error>
}

final class RepositoriesAPIController: RepositoriesAPIControllerProtocol {
    let networkController: NetworkServiceProtocol
    
    init(networkController: NetworkServiceProtocol) {
        self.networkController = networkController
    }
    
    func getBranchDetails(
        ofRepository repository: String,
        fromUser username: String,
        branch: String
    ) -> AnyPublisher<GitHubBranch, Error> {
        let endpoint = Endpoint.branchDetails(
            repository: repository,
            fromUser: username,
            onBranch: branch
        )
        
        return networkController.get(
            type: GitHubBranch.self,
            url: endpoint.url,
            headers: endpoint.headers
        )
    }
    
    func getTree(
        repository: String,
        fromUser username: String,
        treeSHA: String
    ) -> AnyPublisher<VersionControlTree, Error> {
        let endpoint = Endpoint.trees(
            repository: repository,
            fromUser: username,
            treeSHA: treeSHA
        )
        
        return networkController.get(
            type: VersionControlTree.self,
            url: endpoint.url,
            headers: endpoint.headers
        )
    }
}
