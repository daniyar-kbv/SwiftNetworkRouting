# SwiftNetworkRouting

SwiftNetworkRouting is a routing library that helps you build a simple network layer for sending HTTP requests.

## Description

The SwiftNetworkRouting suits you if you want to build the network layer for your app quickly. The framework is made for simple applications, you can only send HTTP requests and receive decoded model instances. The library helps you to build requests quickly and helps you to decode the received data to your Model.

## Requirements

* Cocoapods
* iOS deployment target 10.0+

## Installation

SwiftNetworkRouting is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftNetworkRouting'
```

## Usage

First, you have to create an enum implementing the EndPoint protocol. 
Example:

```swift
import SwiftNetworkRouting

enum MyEndPoint: EndPoint {
    case getTestData
    case sendTestData(message: String)
    case detailedData(id: Int)
    
    var baseURL: URL {
        return URL(string: "http://127.0.0.1:8000")!
    }
    
    var path: String {
        switch self {
        case .getTestData:
            return "/test/data/"
        case .sendTestData:
            return "/test/"
        case .detailedData(let id):
            return "/test/data/\(id)/"
        }
    }
    
    var bodyParameters: [String: Any]? {
        switch self {
        case .sendTestData(let message):
            return [
                "message": message
            ]
        default:
            return nil
        }
    }
    
    var urlParameters: [String: Any]? {
        switch self {
        case .getTestData:
            return [
                "test_param": 1
            ]
        default:
            return nil
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .sendTestData:
            return .post
        default:
            return .get
        }
    }
    
    var baseHeaders: [String: String]? {
        return [
            "Authorization": "Token"
        ]
    }
    
    var additionalHeaders: [String: String]? {
        switch self {
        case .getTestData:
            return [
                "Accept-Language": "ru"
            ]
        default:
            return nil
        }
    }
    
    var contentType: ContentType {
        switch self {
        case .sendTestData:
            return .multiPartFormData
        default:
            return .json
        }
    }
}
```

After that, the model to which response data will be decoded needs to be created.
Example:

```swift
class TestResponse: Codable {
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}
```

Then you have to create the `Router` instance with EndPoint enum.
Example:

``` swift
let router = Router<MyEndPoint>()
```

To send HTTP request, use Router's `request` method.
Exampe:

```swift
router.request(.sendTestData(message: "Hello world!"), returning: TestResponse.self) { error, response in
    /// Use error message or the `TestResponse` instance.
}
```

### Logger customization

By the default logger console output look like this:

For request
```console
- - - - - - - - - - OUTGOING - - - - - - - - - - 

http://127.0.0.1:8000/test/ 


POST /test/? HTTP/1.1 

HOST: 127.0.0.1
Authorization: Token 

{
   message: Hello world! 
}

- - - - - - - - - -  END - - - - - - - - - - 
```
For response
```console
- - - - - - - - - - INCOMING - - - - - - - - - - 

http://127.0.0.1:8000/test/ 


404 /test/? HTTP/1.1 

HOST: 127.0.0.1


- - - - - - - - - -  END - - - - - - - - - - 
```

To implemet your own Logger, you need to create class implementing NetworkLogger protocol.
Example:

```swift
class MyLogger: NetworkLogger {
    func logRequest(route: EndPoint) {
        print("Sending request to \(route.buildURL())")
    }
    
    func logResponse(response: HTTPURLResponse?, data: Data?) {
        print("Received response from \(response?.url)")
    }
}
```

And Then assign the logger instance to Router's logger field.
Example:

```swift
let router = Router<MyEndPoint>()

router.logger = MyLogger()
```

Or you can initialize the Router with a custom logger.
Example:

```swift
let logger = MyLogger()

let router = Router<MyEndPoint>(logger: logger)
```

### Error handling customization

To customize default error messages you can create class implementing `ErrorHandler` protocol.
Example:

```swift
class MyErrorHandler: ErrorHandler {
    var noDataErrorMessage: String = "No data"
    
    var unableToDecodeErrorMessage: String = "Unable to decode"
    
    func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
        case 200...299:
            return .success
        default:
            return .failure("Failed")
        }
    }
}
```

Then your `ErrorHandler` instance should be assigned to `Router`'s `errorHandler` field.
Example:

```swift
let router = Router<MyEndPoint>(logger: logger)

router.errorHandler = MyErrorHandler()
```

Or you can initialize the Router with a custom error handler.
Example:

```swift
let errorHandler = MyErrorHandler()

let router = Router<MyEndPoint>(errorHandler: errorHandler)
```

## Example project

Coming soon...

## Author

Daniyar Kurmanbayev, daniyar.kbv@gmail.com

## License

SwiftNetworkRouting is available under the MIT license. See the LICENSE file for more info.
