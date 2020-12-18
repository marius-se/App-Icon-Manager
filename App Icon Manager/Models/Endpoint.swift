//
//  Endpoint.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 18.12.20.
//

import Foundation

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
        return ["Accept": "application/vnd.github.v3+json"]
    }
}

extension Endpoint {
    static func branchDetails(
        repository: String,
        username: String,
        branch: String
    ) -> Self {
        return Endpoint(
            path: "/repos/\(username)/\(repository)/branches/\(branch)"
        )
    }
    
    static func trees(
        repository: String,
        username: String,
        treeSHA: String
    ) -> Self {
        return Endpoint(
            path: "/repos/\(username)/\(repository)/git/trees/\(treeSHA)"
        )
    }
}
