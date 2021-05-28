//
//  Router.swift
//  SwiftNetworkRouting
//
//  Created by Daniyar Kurmanbayev on 4/29/21.
//

import Foundation
import Alamofire

/// The `Router` is the main class used for sending HTTP requests.
/// The `Router` has to be created with a specified `EndPoint` structure.
public class Router<EP: EndPoint> {
    
    /// The logger of the router, the default logger is used by the default.
    /// You can assign your logger to this field.
    public var logger: NetworkLogger = DefaultNetworkLogger()
    
    /// The error handler of the router, `DefaultErrorHandler` class instance is used by default.
    /// You can assign your error handler to this field.
    public var errorHandler: ErrorHandler = DefaultErrorHandler()
    
    /// The constructor.
    /// You can implement your logger and use it in the constructor.
    public init(logger: NetworkLogger? = nil, errorHandler: ErrorHandler? = nil) {
        if let logger = logger {
            self.logger = logger
        }
        if let errorHandler = errorHandler {
            self.errorHandler = errorHandler
        }
    }
    
    /// The `request` methods sends the HTTP request according to `EndPoin`t type specified in parameters.
    /// You have to specify returning class so the compiler which generic class is used for decoding.
    /// Completion handler returns the error string and returning class instance.
    public func request<T>(_ route: EP, returning: T.Type, completion: @escaping(_ error: String?,_ module: T?)->()) where T : Codable {
        guard let url = route.buildURL() else { return }
        logger.logRequest(route: route)
        switch route.contentType {
        case .json:
            AF.request(url, method: route.httpMethod.alamofireMethod, parameters: route.bodyParameters, encoding: JSONEncoding(), headers: route.buildHeaders()).responseData() { response in
                self.dataCompletion(response: response) { error, response in
                    completion(error, response)
                }
            }
        case .multiPartFormData:
            AF.upload(
                multipartFormData: route.buildMultipartFormData(),
                to: url,
                usingThreshold: .zero,
                method: route.httpMethod.alamofireMethod,
                headers: route.buildHeaders(), interceptor: nil,
                fileManager: .default
            ).responseData(completionHandler: { response in
                self.dataCompletion(response: response) { error, response in
                    completion(error, response)
                }
            })
        }
    }

    func dataCompletion<T>(response: AFDataResponse<Data>, completion: @escaping(_ error:String?,_ module: T?)->()) where T : Codable {
        guard let res = response.response else {
            completion(response.error?.localizedDescription, nil)
            return
        }
        logger.logResponse(response: res, data: response.data)
        let result = errorHandler.handleNetworkResponse(res)
        switch result {
        case .success:
            guard let responseData = response.data else {
                completion(errorHandler.noDataErrorMessage, nil)
                return
            }
            do {
                let apiResponse = try JSONDecoder().decode(T.self, from: responseData)
                completion(nil, apiResponse)
            }
            catch {
                completion(errorHandler.unableToDecodeErrorMessage, nil)
            }
        case .failure(let error):
            completion(error, nil)
        }
    }
}
