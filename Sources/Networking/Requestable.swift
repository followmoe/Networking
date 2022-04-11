//
//  Client.swift
//  
//
//  Created by Moritz Müller on 08.04.22.
//

import Foundation

@available(iOS 15.0, *)
@available(macOS 12.0, *)
public protocol Requestable {
    
    var endpoint: Endpoint { get }
    var environment: Environment { get }
}

@available(iOS 15.0, *)
@available(macOS 12.0, *)
public class DefaultRequestable<T: Decodable>: Requestable {
    
    private(set) public var endpoint: Endpoint
    private(set) public var environment: Environment
    private let requestHandler: RequestHandler
    private let validationHandler: ValidationHandler
    
    init(endpoint: Endpoint, environment: Environment) {
        self.environment = environment
        self.endpoint = endpoint
        self.validationHandler = DefaultValidationHandler()
        self.requestHandler = DefaultRequestHandler(environment: environment)
    }
    

    func send() async -> Task<T, Error> {
        
        let task = Task(priority: .high) { () -> T in
            let requestResult = await requestHandler.sendRequest(requestable: self)
            try Task.checkCancellation()
            
            switch requestResult {
            case .success(let (response, data)):
                return try validate(response: response, data: data)
            case .failure(let error):
                throw error
            }
        }
        
        return task
    }
    
    private func validate(response: HTTPURLResponse?, data: Data?) throws -> T {
        do {
            let result: Result<T, RequestError> = try validationHandler.validate(self, response: response, data: data)
            switch result {
            case .success(let object):
                return object
            case .failure(let error):
                throw error
            }
        } catch {
           throw RequestError.unknown
        }
    }
}
