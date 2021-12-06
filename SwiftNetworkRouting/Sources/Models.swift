//
//  Models.swift
//  SwiftNetworkRouting
//
//  Created by Daniyar Kurmanbayev on 5/26/21.
//

import Foundation

/// `UploadingFile` class is used for uploading files as `Data`.
/// For uploading images you can use instances of this class in the body parameters of your `EndPoint`.
public class UploadingFile {
    
    /// The `Data` instance of the file.
    public var data: Data
    
    /// The file name including the file extension.
    public var fileName: String 
    
    /// The MIME type is a label used to identify a type of data.
    /// The field is optional.
    public var mimeType: String?
    
    /// The constructor.
    public init(data: Data, fileName: String, mimeType: String? = nil) {
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

