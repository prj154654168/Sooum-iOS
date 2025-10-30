//
//  UserRequest.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

enum UserRequest: BaseRequest {
    
    /// 가입 가능 여부 확인
    case checkAvailable(encryptedDeviceId: String)
    /// 추천 닉네임 조회
    case nickname
    /// 닉네임 유효성 검사
    case validateNickname(nickname: String)
    /// 닉네임 업데이트
    case updateNickname(nickname: String)
    /// 이미지 업로드할 공간 확보
    case presignedURL
    /// 이미지 업데이트
    case updateImage(imageName: String)
    /// fcmToken 업데이트
    case updateFCMToken(fcmToken: String)
    /// 카드추가 가능 여부 확인
    case postingPermission
    
    var path: String {
        switch self {
        case .checkAvailable:
            return "/api/members/check-available"
        case .nickname:
            return "/api/members/generate-nickname"
        case .validateNickname:
            return "/api/members/validate-nickname"
        case .updateNickname:
            return "/api/members/nickname"
        case .presignedURL:
            return "/api/images/profile"
        case .updateImage:
            return "/api/members/profile-img"
        case .updateFCMToken:
            return "/api/members/fcm"
        case .postingPermission:
            return "/api/members/permissions/posting"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .checkAvailable, .validateNickname:
            return .post
        case .updateNickname, .updateImage, .updateFCMToken:
            return .patch
        case .nickname, .presignedURL, .postingPermission:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case let .checkAvailable(encryptedDeviceId):
            return ["encryptedDeviceId": encryptedDeviceId]
        case let .updateNickname(nickname):
            return ["nickname": nickname]
        case let .validateNickname(nickname):
            return ["nickname": nickname]
        case let .updateImage(imageName):
            return ["name": imageName]
        case let .updateFCMToken(fcmToken):
            return ["fcmToken": fcmToken]
        default:
            return [:]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .nickname, .presignedURL, .postingPermission:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self{
        case .updateFCMToken, .postingPermission:
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
