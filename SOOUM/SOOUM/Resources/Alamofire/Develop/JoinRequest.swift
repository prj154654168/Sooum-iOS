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
    
    var path: String {
        switch self {
        case .validateNickname(let nickname):
            return "/profiles/nickname/\(nickname)/available"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .validateNickname:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .validateNickname:
            return [:]
        default:
            return [:]
        }
    }
        
    var encoding: ParameterEncoding {
        switch self {
        case .validateNickname:
            return URLEncoding.queryString
        default:
            return URLEncoding.queryString
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        case .validateNickname:
            return .none
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
            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}
