//
//  File.swift
//  
//
//  Created by Moritz Müller on 08.04.22.
//

import Foundation

public protocol RequestHandler {
    func sendRequest<R: Requestable>(requestable: R) async -> Result<(HTTPURLResponse?, Data?), RequestError>
}

public struct DefaultRequestHandler: RequestHandler {
    
    private let environment: Environment
    
    init(environment: Environment) {
        self.environment = environment
    }
    
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    public func sendRequest<R: Requestable>(
        requestable: R
    ) async -> Result<(HTTPURLResponse?, Data?), RequestError> {
        
        guard let request = makeRequest(requestable: requestable) else {
            return .failure(.unknown)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.noResponse)
            }
            return .success((response, data))
        } catch {
            return .failure(.unknown)
        }
    }
    
    private func makeRequest<R: Requestable>(requestable: R) -> URLRequest? {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = environment.host
        components.path = requestable.endpoint.path
        
        if let parameters = requestable.endpoint.urlParameter {
            components.setQueryItems(with: parameters)
        }
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        if let headers = environment.headers {
            headers.forEach { request.addValue(($0.value as? String) ?? "", forHTTPHeaderField: $0.key) }
        }
        
        request.httpMethod = requestable.endpoint.method.rawValue
        request.cachePolicy = requestable.environment.cachePolicy
        
        if let body = requestable.endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        return request
    }
}

public extension URLComponents {

    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
