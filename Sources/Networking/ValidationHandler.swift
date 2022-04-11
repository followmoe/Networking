//
//  File.swift
//  
//
//  Created by Moritz Müller on 08.04.22.
//

import Foundation

public protocol ValidationHandler {
    func validate<T: Decodable, R: Requestable>(_ requestable: R, response: HTTPURLResponse?, data: Data?) throws -> Result<T, RequestError>
}

public struct DefaultValidationHandler: ValidationHandler {
    
    private static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    public func validate<T: Decodable, R: Requestable>(_ requestable: R, response: HTTPURLResponse?, data: Data?) throws -> Result<T, RequestError> {
        guard let response = response else {
            return .failure(.noResponse)
        }
        do {
            switch response.statusCode {
            case 200...299:
                
                guard let data = data else {
                    return .failure(.unknown)
                }
                
                let decodedResponse = try Self.decoder.decode(T.self, from: data)
                return .success(decodedResponse)
            case 401:
                return .failure(.unauthorized)
            default:
                return .failure(.unexpectedStatusCode)
            }
        } catch {
            return .failure(.decode)
        }
    }
}
