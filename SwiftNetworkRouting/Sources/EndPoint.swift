//
//  EndPoint.swift
//  SwiftNetworkRouting
//
//  Created by Daniyar Kurmanbayev on 4/29/21.
//

import Foundation
import Alamofire


/// `EndPoint` protocol is used to create endpoints to use for HTTP requests.
public protocol EndPoint {
    
    /// Base URL for a group of routes.
    /// If the server endpoints have one same part you have to specify it in this field.
    /// 
    /// Emample: if the target URLs are "https://google.com/api/some/service/" and "https://google.com/api/other/service/", you can use URL(string: "https://google.com/api") as your base URL.
    var baseURL: URL {get}
    
    /// The end of the targer url
    ///
    /// Emample: if the target URLs are "https://google.com/api/some/service/, you can use "/some/service/" as path.
    var path: String {get}
    
    /// Parameters that will be incuided in request body
    var bodyParameters: [String: Any]? {get}
    
    /// Parameters that will be included as query parameters in the URL of the request.
    var urlParameters: [String: Any]? {get}
    
    /// The HTTP method of the request
    var httpMethod: HttpMethod {get}
    
    /// HTTP headers which are same for group of routes
    ///
    /// Example: Autorization header
    var baseHeaders: [String: String]? {get}
    
    /// HTTP headers which are the same for a group of routes.
    var additionalHeaders: [String: String]? {get}
    
    /// The type of request's body (JSON, Multipart Form Data)
    var contentType: ContentType {get}
}

public extension EndPoint {

    func buildHeaders() -> HTTPHeaders {
        var headers = [String: String]()
        if let baseHeaders = baseHeaders {
            headers.merge(baseHeaders, uniquingKeysWith: { $1 })
        }
        if let additionalHeaders = additionalHeaders {
            headers.merge(additionalHeaders, uniquingKeysWith: { $1 })
        }
        return HTTPHeaders(headers)
    }
    
    
    func buildURL() -> URL? {
        guard let parameters = urlParameters else {
            return baseURL.appendingPathComponent(path)
        }
        let queryItems = parameters.map({ URLQueryItem(name: $0.key, value: "\($0.value)") })
        var urlComps = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        urlComps?.queryItems = queryItems
        return urlComps?.url
    }
    
    func buildMultipartFormData() -> ((MultipartFormData) -> Void) {
        return { multipartFormData in
            for (key, value) in bodyParameters ?? Parameters() {
                if let url = value as? URL {
                    multipartFormData.append(url, withName: key)
                } else if let image = value as? UploadingFile {
                    multipartFormData.append(image.data, withName: key, fileName: image.fileName, mimeType: image.mimeType)
                } else if let data = value as? Data {
                    multipartFormData.append(data, withName: key)
                } else if let data = "\(value)".data(using: String.Encoding.utf8, allowLossyConversion: false) {
                    multipartFormData.append(data, withName: key)
                }
            }
        }
    }
}
