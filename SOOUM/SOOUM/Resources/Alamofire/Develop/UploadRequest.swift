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
        switch self {
        case .defaultImages, .uploadMyImage, .presignedURL:
            return URLEncoding.queryString
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        case .defaultImages, .presignedURL:
                .access
        case .uploadMyImage:
                .none
        }
    }
        
    func asURLRequest() throws -> URLRequest {

        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(self.path) {
            var request = URLRequest(url: url)
            request.method = self.method
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
