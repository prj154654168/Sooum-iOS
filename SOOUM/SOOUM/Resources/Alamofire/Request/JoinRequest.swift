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
    case registerUser(userName: String, imageName: String)
    
    var path: String {
        switch self {
        case .validateNickname(let nickname):
            return "/profiles/nickname/available"
        case .profileImagePresignedURL:
            return "/imgs/profiles/upload"
        case .registerUser:
            return "/profiles"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .validateNickname:
            return .post
        case .registerUser:
            return .patch
        default:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case let .validateNickname(nickname):
            return ["nickname": nickname]
        case .profileImagePresignedURL:
            return ["extension": "JPEG"]
        case .registerUser(let nickname, let profileImg):
            let profileImg = profileImg.isEmpty ? "" : profileImg
            return [
                "nickname": nickname,
                "profileImg": profileImg.isEmpty ? nil : profileImg
            ].compactMapValues { $0 }
        }
    }
        
    var encoding: ParameterEncoding {
        switch self {
        case .registerUser, .validateNickname:
            return JSONEncoding.default
        default:
            return URLEncoding.queryString
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        case .validateNickname:
            return .none
        default:
            return .access
        }
    }
        
    func asURLRequest() throws -> URLRequest {
        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(self.path) {
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
            
            let encoded = try self.encoding.encode(request, with: self.parameters)

            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}
