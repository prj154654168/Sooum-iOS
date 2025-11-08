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
    /// 프로필 이미지 업로드할 공간 조회
    case presignedURL
    /// 이미지 업데이트
    case updateImage(imageName: String)
    /// fcmToken 업데이트
    case updateFCMToken(fcmToken: String)
    /// 카드추가 가능 여부 확인
    case postingPermission
    /// 프로필 조회
    case profile(userId: String?)
    /// 나의 프로필 업데이트
    case updateMyProfile(nickname: String?, imageName: String?)
    /// 나의 피드 카드 조회
    case feedCards(userId: String, lastId: String?)
    /// 나의 답카드 조회
    case myCommentCards(lastId: String?)
    /// 팔로워 조회
    case followers(userId: String, lastId: String?)
    /// 팔로우 조회
    case followings(userId: String, lastId: String?)
    /// 팔로우 요청 및 취소
    case updateFollowing(userId: String, isFollow: Bool)
    /// 상대방 차단
    case updateBlocked(id: String, isBlocked: Bool)
    
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
        case let .profile(userId):
            
            if let userId = userId {
                return "/api/members/profile/info/\(userId)"
            } else {
                return "/api/members/profile/info/me"
            }
        case .updateMyProfile:
            
            return "/api/members/profile/info/me"
        case let .feedCards(userId, lastId):
            
            if let lastId = lastId {
                return "/api/members/\(userId)/cards/feed\(lastId)"
            } else {
                return "/api/members/\(userId)/cards/feed"
            }
        case .myCommentCards:
            
            return "/api/members/me/cards/comment"
        case let .followers(userId, lastId):
            
            if let lastId = lastId {
                return "/api/members/\(userId)/followers/\(lastId)"
            } else {
                return "/api/members/\(userId)/followers"
            }
        case let .followings(userId, lastId):
            
            if let lastId = lastId {
                return "/api/members/\(userId)/following/\(lastId)"
            } else {
                return "/api/members/\(userId)/following"
            }
        case let .updateFollowing(userId, isFollow):
            
            if isFollow {
                return "/api/members/follow"
            } else {
                return "/api/members/\(userId)/unfollow"
            }
        case let .updateBlocked(id, _):
            
            return "/api/blocks/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .checkAvailable, .validateNickname:
            return .post
        case .updateNickname, .updateImage, .updateFCMToken, .updateMyProfile:
            return .patch
        case let .updateFollowing(_, isFollow):
            return isFollow ? .post : .delete
        case let .updateBlocked(_, isBlocked):
            return isBlocked ? .post : .delete
        default:
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
        case let .updateMyProfile(nickname, imageName):
            var dictionary: [String: Any] = [:]
            if let nickname = nickname {
                dictionary["nickname"] = nickname
            }
            if let imageName = imageName {
                dictionary["profileImgName"] = imageName
            }
            return dictionary
        case let .updateFollowing(userId, isFollow):
            return isFollow ? ["userId": userId] : [:]
        default:
            return [:]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .checkAvailable,
            .updateNickname,
            .validateNickname,
            .updateImage,
            .updateFCMToken,
            .updateMyProfile:
            return JSONEncoding.default
        case .updateFollowing:
            return URLEncoding.queryString
        default:
            return URLEncoding.default
        }
    }
    
    var authorizationType: AuthorizationType {
        return .access
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
