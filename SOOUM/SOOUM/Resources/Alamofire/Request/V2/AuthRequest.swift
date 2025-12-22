//
//  AuthRequest.swift
//  SOOUM
//
//  Created by 오현식 on 10/26/24.
//

import Alamofire

enum AuthRequest: BaseRequest {
    
    /// RSA 공개 키 요청
    case publicKey
    /// 회원가입
    case signUp(
        encryptedDeviceId: String,
        isNotificationAgreed: Bool,
        nickname: String,
        profileImageName: String?
    )
    /// 로그인
    case login(encryptedDeviceId: String)
    /// 재인증
    case reAuthenticationWithRefreshSession(token: Token)
    /// 회원탈퇴
    case withdraw(token: Token, reason: String)
    
    var path: String {
        switch self {
        case .publicKey:
            return "/api/rsa/public-key"
        case .signUp:
            return "/api/auth/sign-up"
        case .login:
            return "/api/auth/login"
        case .reAuthenticationWithRefreshSession:
            return "/api/auth/token/reissue"
        case .withdraw:
            return "/api/auth/withdrawal"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .publicKey:
            return .get
        case .login, .signUp, .reAuthenticationWithRefreshSession:
            return .post
        case .withdraw:
            return .delete
        }
    }
    
    var parameters: Parameters {
        switch self {
        case let .signUp(encryptedDeviceId, isNotificationAgreed, nickname, profileImageName):
            var memberInfo: [String: Any]
            if let profileImageName = profileImageName {
                memberInfo = [
                    "encryptedDeviceId": encryptedDeviceId,
                    "deviceType": "IOS",
                    "deviceModel": Info.deviceModel,
                    "deviceOsVersion": Info.iOSVersion,
                    "isNotificationAgreed": isNotificationAgreed,
                    "nickname": nickname,
                    "profileImage": profileImageName
                ]
            } else {
                memberInfo = [
                    "encryptedDeviceId": encryptedDeviceId,
                    "deviceType": "IOS",
                    "deviceModel": Info.deviceModel,
                    "deviceOsVersion": Info.iOSVersion,
                    "isNotificationAgreed": isNotificationAgreed,
                    "nickname": nickname
                ]
            }
            return [
                "memberInfo": memberInfo,
                "policy": [
                    "agreedToTermsOfService": true,
                    "agreedToLocationTerms": true,
                    "agreedToPrivacyPolicy": true
                ] as [String: Any]
            ]
        case let .login(encryptedDeviceId):
            return [
                "encryptedDeviceId": encryptedDeviceId,
                "deviceType": "IOS",
                "deviceModel": Info.deviceModel,
                "deviceOsVersion": Info.iOSVersion
            ]
        case let .reAuthenticationWithRefreshSession(token):
            return [
                "accessToken": token.accessToken,
                "refreshToken": token.refreshToken
            ]
            case let .withdraw(token, reaseon):
                return [
                    "accessToken": token.accessToken,
                    "refreshToken": token.refreshToken,
                    "reason": reaseon
                ]
        default:
            return [:]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .publicKey:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        case .withdraw:
            return .access
        default:
            return .none
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
            return .init(url: URL(string: "")!)
        }
    }
}
