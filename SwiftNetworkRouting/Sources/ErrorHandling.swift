//
//  NetworkResponse.swift
//  SwiftNetworkRouting
//
//  Created by Daniyar Kurmanbayev on 4/30/21.
//

import Foundation

/// The error handler is used to handle network errors and return appropriate error messages by a router.
public protocol ErrorHandler {
    
    /// The error message returned if the response body is empty.
    var noDataErrorMessage: String { get set }
    
    /// The error message returned if the response data could not be decoded.
    var unableToDecodeErrorMessage: String { get set }
    
    /// This is the main method for error handling which is used by `Router`.
    /// If you want to implement your logic of error handling you can override `handleNetworkResponse` method.
    func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>
}

/// 'NetworkResponse' represents default response types of the request with texts for the errors.
public enum NetworkResponse: String {
    
    /// Success response type, used for 100-299 HTTP sattus codes.
    case success
    
    /// Bad requset response type, used for 400 HTTP status code.
    case badRequest = "Bad request"
    
    /// Authentication error response type, used for 403 HTTP status code.
    case authenticationError = "You need to be authenticated first."
    
    /// Client error response type, used for 401-499 HTTP status codes.
    case clientError = "Some client error occured"
    
    /// Server error response type, used for 500-599 HTTP status codes.
    case serverError = "Server error"
    
    /// Failed error response type, used for other HTTP status codes.
    case failed = "Network request failed."
    
    /// No data error message, used when response returned with no data to decode.
    case noData = "Response returned with no data to decode."
    
    /// Unable to decode error response type, used when the router cannot decode the data to the specified class.
    case unableToDecode = "We could not decode the response."
}

/// The result type is used by the `Router` to identify whether the response succeeded or not.
/// If not the string passed with the failure case will be returned.
public enum Result<String> {
    case success
    case failure(String)
}

/// The default error handler class.
public class DefaultErrorHandler: ErrorHandler {
    
    /// The error message returned if the response body is empty.
    public var noDataErrorMessage: String = NetworkResponse.noData.rawValue
    
    /// The error message returned if the response data could not be decoded.
    public var unableToDecodeErrorMessage: String = NetworkResponse.unableToDecode.rawValue
    
    
    /// The method is used to get an error message depending on the `NetworkResponse` type.
    /// By default, this method returns the raw values of `NetworkResponse`.
    /// `getNetworkError` method is used inside of the handleNetworkResponse.
    /// If you want to change only error messages for default response types in `NetworkResponse` you can override this method.
    public lazy var getNetworkError: ((_ responseType: NetworkResponse) -> String) = getNetworkErrorDefault
    
    /// This is the main method for error handling which is used by `Router`.
    public func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 100...299: return .success
        case 400: return .failure(getNetworkError(.badRequest))
        case 403: return .failure(getNetworkError(.authenticationError))
        case 400...499: return .failure(getNetworkError(.clientError))
        case 500...599: return .failure(getNetworkError(.serverError))
        default: return .failure(getNetworkError(.failed))
        }
    }
    
    fileprivate func getNetworkErrorDefault(_ responseType: NetworkResponse) -> String {
        return responseType.rawValue
    }
}
