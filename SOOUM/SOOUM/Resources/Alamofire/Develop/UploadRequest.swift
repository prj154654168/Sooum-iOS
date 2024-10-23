//
//  UploadRequest.swift
//  SOOUM
//
//  Created by JDeoks on 10/23/24.
//

import UIKit

import Alamofire

enum UploadRequest: BaseRequest {
    
    case defaultImages
    /// 이미지 업로드할 url, 이미지 이름 fetch
    case presignedURL(fileName: String)
    /// 이미지를 URL로 업로드
    case myImage(image: UIImage, presignedURL: URL)
    
    var path: String {
        switch self {
        case .defaultImages:
            return "/imgs/default"
        case .presignedURL:
            return "/imgs/cards/upload?extension=jpeg"
        case .myImage:
            return "" // presignedURL로 직접 요청
        }
    }
        
    var method: HTTPMethod {
        switch self {
        case .myImage:
            return .put
        case .defaultImages, .presignedURL:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .defaultImages, .presignedURL, .myImage:
            return [:]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .defaultImages, .myImage:
            return URLEncoding.queryString
        case .presignedURL:
            return JSONEncoding.default
        }
    }
        
    func asURLRequest() throws -> URLRequest {

        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(self.path) {
            var request = URLRequest(url: url)
            request.method = self.method
            request.setValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjgzMDgwNTQsImV4cCI6NDgzODcwODA1NCwic3ViIjoiQWNjZXNzVG9rZW4iLCJpZCI6NjMxMTExNzU3MDY3NzMxMTAwLCJyb2xlIjoiVVNFUiJ9.bD1ktqefCL3gETkXo3Prwx5LsnkCNlxF38PMXId2VVE", forHTTPHeaderField: "Authorization")
            request.setValue(
                Constants.ContentType.json.rawValue,
                forHTTPHeaderField: Constants.HTTPHeader.contentType.rawValue
            )
            request.setValue(
                Constants.ContentType.json.rawValue,
                forHTTPHeaderField: Constants.HTTPHeader.acceptType.rawValue
            )

            let encoded = try encoding.encode(request, with: self.parameters)
            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
    
}
