//
//  AuthRequest.swift
//  SOOUM
//
//  Created by 오현식 on 10/26/24.
//

import Foundation

import Alamofire


enum AuthRequest: BaseRequest {
    
    /// RSA 공개 키 요청
    case getPublicKey
    /// 로그인
    case login(encryptedDeviceId: String)
    /// 회원가입
    case signUp(
        encryptedDeviceId: String,
        firebaseToken: String,
        isAllowNotify: Bool,
        isAllowTermOne: Bool,
        isAllowTermTwo: Bool,
        isAllowTermThree: Bool
    )
    /// 재인증
    case reAuthenticationWithRefreshSession
    
    var path: String {
        switch self {
        case .getPublicKey:
            return "/users/key"
        case .login:
            return "/users/login"
        case .signUp:
            return "/users/sign-up"
        case .reAuthenticationWithRefreshSession:
            return "/users/token"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getPublicKey:
            return .get
        case .login, .signUp, .reAuthenticationWithRefreshSession:
            return .post
        }
    }
    
    var parameters: Parameters {
        switch self {
        case let .login(encryptedDeviceId):
            return ["encryptedDeviceId": encryptedDeviceId]
        case let .signUp(
            encryptedDeviceId,
            firebaseToken,
            isAllowNotify,
            isAllowTermOne,
            isAllowTermTwo,
            isAllowTermThree
        ):
            return [
                "member": [
                    "encryptedDeviceId": encryptedDeviceId,
                    "deviceType": "IOS",
                    "firebaseToken": firebaseToken,
                    "isAllowNotify": isAllowNotify
                ] as [String: Any],
                "policy": [
                    "isAllowTermOne": isAllowTermOne,
                    "isAllowTermTwo": isAllowTermTwo,
                    "isAllowTermThree": isAllowTermThree
                ] as [String: Any]
            ]
        default:
            return [:]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .login, .signUp:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        case .reAuthenticationWithRefreshSession:
            return .refresh
        default:
            return .none
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(self.path) {
            var request = URLRequest(url: url)
            request.method = self.method
            
            // 재인증 API는 access와 refresh 둘 다 사용
            switch self.authorizationType {
            case .refresh:
                
                let authPayloadForAccess = AuthManager.shared.authPayloadByAccess()
                let authKeyForAccess = authPayloadForAccess.keys.first! as String
                request.setValue(authPayloadForAccess[authKeyForAccess], forHTTPHeaderField: authKeyForAccess)
                
                let authPayloadForRefresh = AuthManager.shared.authPayloadByRefresh()
                let authKeyForRefresh = authPayloadForRefresh.keys.first! as String
                request.setValue(authPayloadForRefresh[authKeyForRefresh], forHTTPHeaderField: authKeyForRefresh)
            default:
                break
            }
            
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
