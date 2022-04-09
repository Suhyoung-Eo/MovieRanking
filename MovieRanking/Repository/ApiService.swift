//
//  APIService.swift
//  MovieRanking
//
//  Created by Suhyoung Eo on 2022/02/03.
//

import Foundation

enum NetworkError: Error {
    case decodingError
    case domainError
    case urlError
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

struct Resource<T: Codable> {
    let url: URL
    var httpMethod: HttpMethod = .get
    var body: Data? = nil
}

extension Resource {
    init(url: URL) {
        self.url = url
    }
}

class ApiService {
    
    func fetchData<T>(resource: Resource<T>, completion: @escaping (Result<T, NetworkError>) -> Void) {
        DispatchQueue.global(qos: .default).async {
            if let data = try? Data(contentsOf: resource.url) {
                DispatchQueue.main.async {
                    let result = try? JSONDecoder().decode(T.self, from: data)
                    if let result = result {
                        completion(.success(result))
                    } else {
                        completion(.failure(.decodingError))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(.domainError))
                }
            }
        }
    }
}
