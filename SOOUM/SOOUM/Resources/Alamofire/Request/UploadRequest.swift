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
    case presignedURL
    /// 이미지를 URL로 업로드
    case uploadMyImage(image: UIImage, presignedURL: URL)
    
    var path: String {
        switch self {
        case .defaultImages:
            return "/imgs/default"
        case .presignedURL:
            return "/imgs/cards/upload"
        case .uploadMyImage:
            return "" // presignedURL로 직접 요청
        }
    }
        
    var method: HTTPMethod {
        switch self {
        case .uploadMyImage:
            return .put
        case .defaultImages, .presignedURL:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .defaultImages, .uploadMyImage:
            return [:]
        case .presignedURL:
            return ["extension": "jpeg"]
        }
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.queryString
    }
    
    var authorizationType: AuthorizationType {
        return .access
    }
    
    var version: APIVersion {
        return .v1
    }
        
    func asURLRequest() throws -> URLRequest {

        let pathWithAPIVersion = self.path + self.version.rawValue
        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(pathWithAPIVersion) {
            var request = URLRequest(url: url)
            request.method = self.method
            
            request.setValue(self.authorizationType.rawValue, forHTTPHeaderField: "AuthorizationType")
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
