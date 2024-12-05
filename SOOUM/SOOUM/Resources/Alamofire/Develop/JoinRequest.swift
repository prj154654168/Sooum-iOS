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
            return "/profiles/nickname/\(nickname)/available"
        case .profileImagePresignedURL:
            return "/imgs/profiles/upload"
        case .registerUser:
            return "/profiles"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .registerUser:
            return .patch
        default:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .validateNickname:
            return [:]
        case .profileImagePresignedURL:
            return ["extension": "JPEG"]
        case .registerUser(let nickname, let profileImg):
            return [
                "nickname": nickname,
                "profileImg": profileImg
            ]
        }
    }
        
    var encoding: ParameterEncoding {
        switch self {
        case .registerUser:
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
            
            let authPayload = AuthManager.shared.authPayloadByAccess()
            let authKey = authPayload.keys.first! as String
            request.setValue(authPayload[authKey], forHTTPHeaderField: authKey)
            
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
