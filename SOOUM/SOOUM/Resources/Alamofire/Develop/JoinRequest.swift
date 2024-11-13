//
//  JoinRequest.swift
//  SOOUM
//
//  Created by JDeoks on 11/7/24.
//

import Foundation

import Alamofire

enum JoinRequest: BaseRequest {
    
    case validateNickname(nickname: String)
    case profileImagePresignedURL
    
    var path: String {
        switch self {
        case .validateNickname(let nickname):
            return "/profiles/nickname/\(nickname)/available"
        case .profileImagePresignedURL:
            return "/imgs/profiles/upload"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .validateNickname, .profileImagePresignedURL:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .validateNickname:
            return [:]
        case .profileImagePresignedURL:
            return [ "extension": "JPEG" ]
        default:
            return [:]
        }
    }
        
    var encoding: ParameterEncoding {
        switch self {
        case .validateNickname, .profileImagePresignedURL:
            return URLEncoding.queryString
        default:
            return URLEncoding.queryString
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        case .validateNickname:
            return .none
        case .profileImagePresignedURL:
            return .access
        default:
            return .none
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
            
            let encoded = try self.encoding.encode(request, with: self.parameters)
            print("\(type(of: self)) - \(#function)", encoded)

            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}
