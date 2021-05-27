//
//  HTTPMEthod.swift
//  SwiftNetworkRouting
//
//  Created by Daniyar Kurmanbayev 5/20/21.
//

import Foundation
import Alamofire

/// HTTP methods that can be used for `Router` request.
public enum HttpMethod: String {
    case connect
    case delete
    case get
    case head
    case options
    case patch
    case post
    case put
    case trace
    
    var alamofireMethod: HTTPMethod {
        switch self {
        case .connect:
            return .connect
        case .delete:
            return .delete
        case .get:
            return .get
        case .head:
            return .head
        case .options:
            return .options
        case .patch:
            return .patch
        case .post:
            return.post
        case .put:
            return .put
        case .trace:
            return .trace
        }
    }
    
    func toStr() -> String {
        return self.rawValue.uppercased()
    }
}
