//
//  Logging.swift
//  SwiftNetworkRouting
//
//  Created by Daniyar Kurmanbayev on 4/30/21.
//

import Foundation
import Alamofire

/// `NetworkLogger` protocol describes the methods used by the `Router` to log network responses and requests.
/// You can write your network logger implementing the `NetworkLogger` protocol and assign it to the logger variable of `Router`.
public protocol NetworkLogger {
    
    /// The method that used to log outgoing request to the console.
    func logRequest(route: EndPoint)
    
    /// The method that used to log incoming response to the console.
    func logResponse(response: HTTPURLResponse?, data: Data?)
}

class DefaultNetworkLogger: NetworkLogger {
    
    func logRequest(route: EndPoint) {
        print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        
        guard let url = route.buildURL() else { return }
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
        let method = route.httpMethod.toStr()
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        
        var logOutput = """
                        \(url) \n\n
                        \(method) \(path)?\(query) HTTP/1.1 \n
                        HOST: \(host)\n
                        """
        for (key,value) in route.buildHeaders().dictionary {
            logOutput += "\(key): \(value) \n"
        }
        if let body = route.bodyParameters {
            logOutput += "\n{\n"
            for (key,value) in body {
                logOutput += "    \(key): \(value) \n"
            }
            logOutput += "}"
        }
        
        print(logOutput)
    }
    
    func logResponse(response: HTTPURLResponse?, data: Data?) {
        print("\n - - - - - - - - - - INCOMING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        
        let urlAsString = response?.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)
        
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        
        let logOutput = """
                        \(urlAsString) \n\n
                        \(response?.statusCode ?? 200) \(path)?\(query) HTTP/1.1 \n
                        HOST: \(host)\n
                        """
        
        print(logOutput)
        
        if let responseData = data {
            do {
                let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                print(jsonData)
            } catch {
                
            }
        }
    }
}
