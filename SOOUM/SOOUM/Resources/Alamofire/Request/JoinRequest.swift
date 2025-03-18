//
//  JoinRequest.swift
//  SOOUM
//
//  Created by JDeoks on 11/7/24.
//

import Foundation

import Alamofire

enum JoinRequest: BaseRequest {
    
    case suspension(encryptedDeviceId: String)
    case validateNickname(nickname: String)
    case profileImagePresignedURL
    case registerUser(userName: String, imageName: String?)
    
    var path: String {
        switch self {
        case .suspension:
            return "/members/suspension"
        case .validateNickname:
            return "/profiles/nickname/available"
        case .profileImagePresignedURL:
            return "/imgs/profiles/upload"
        case .registerUser:
            return "/profiles"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .suspension, .validateNickname:
            return .post
        case .registerUser:
            return .patch
        default:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case let .suspension(encryptedDeviceId):
            return ["encryptedDeviceId": encryptedDeviceId]
        case let .validateNickname(nickname):
            return ["nickname": nickname]
        case .profileImagePresignedURL:
            return ["extension": "JPEG"]
        case .registerUser(let nickname, let profileImg):
            if let profileImg = profileImg {
                return ["nickname": nickname, "profileImg": profileImg]
            } else {
                return ["nickname": nickname]
            }
        }
    }
        
    var encoding: ParameterEncoding {
        switch self {
        case .suspension, .registerUser, .validateNickname:
            return JSONEncoding.default
        default:
            return URLEncoding.queryString
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        case .suspension, .validateNickname:
            return .none
        default:
            return .access
        }
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
            
            let encoded = try self.encoding.encode(request, with: self.parameters)

            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}
