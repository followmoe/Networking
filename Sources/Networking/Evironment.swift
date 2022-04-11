//
//  Environment.swift
//  
//
//  Created by Moritz Müller on 08.04.22.
//

import Foundation

public protocol Environment {
    
    var type: EnvironmentType { get }

    var host: String { get }

    var headers: [String: Any]? { get}

    var cachePolicy: URLRequest.CachePolicy { get }
}

extension Environment {
    
    var type: EnvironmentType {
        .development
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        .reloadIgnoringLocalAndRemoteCacheData
    }
}

public enum EnvironmentType {
    case development
    case staging
    case sandbox
    case production
}
