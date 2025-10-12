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
    #if DEVELOP
    /// 테스트 용 계정 삭제
    case withdraw(token: Token)
    #endif
    
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
        #if DEVELOP
        case .withdraw:
            return "/api/auth/withdrawal"
        #endif
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .publicKey:
            return .get
        case .login, .signUp, .reAuthenticationWithRefreshSession:
            return .post
        #if DEVELOP
        case .withdraw:
            return .delete
        #endif
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
            #if DEVELOP
            case let .withdraw(token):
                return [
                    "accessToken": token.accessToken,
                    "refreshToken": token.refreshToken
                ]
            #endif
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
        #if DEVELOP
        case .withdraw:
            return .access
        #endif
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
