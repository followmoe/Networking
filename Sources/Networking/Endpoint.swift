//
//  Endpoint.swift
//  
//
//  Created by Moritz Müller on 08.04.22.
//

import Foundation

public protocol Endpoint {
    var path: String { get }
    var method: RequestMethod { get }
    var body: [String: String]? { get }
    var urlParameter: [String: String]? { get }
}
