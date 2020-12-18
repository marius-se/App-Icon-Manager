//
//  NetworkService.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 18.12.20.
//

import Foundation
import Combine

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
