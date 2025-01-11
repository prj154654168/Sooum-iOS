//
//  ProfileRequest.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import Foundation

import Alamofire


enum ProfileRequest: BaseRequest {

    case myProfile
    case otherProfile(memberId: String)
    case updateProfile(nickname: String, profileImg: String?)
    case myCards(lastId: String?)
    case otherCards(memberId: String, lastId: String?)
    case myFollowing(lastId: String?)
    case otherFollowing(memberId: String, lastId: String?)
    case myFollower(lastId: String?)
    case otherFollower(memberId: String, lastId: String?)
    case requestFollow(memberId: String)
    case cancelFollow(memberId: String)
    

    var path: String {
        switch self {
        case .myProfile:
            return "/profiles/my"
        case let .otherProfile(memberId):
            return "/profiles/\(memberId)"
        case .updateProfile:
            return "/profiles"
        case .myCards:
            return "/members/feed-cards"
        case let .otherCards(memberId, _):
            return "/members/\(memberId)/feed-cards"
        case .myFollowing:
            return "/profiles/following"
        case let .otherFollowing(memberId, _):
            return "/profiles/\(memberId)/following"
        case .myFollower:
            return "/profiles/follower"
        case let .otherFollower(memberId, _):
            return "/profiles/\(memberId)/follower"
        case .requestFollow:
            return "/followers"
        case let .cancelFollow(memberId):
            return "/followers/\(memberId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .updateProfile:
            return .patch
        case .requestFollow:
            return .post
        case .cancelFollow:
            return .delete
        default:
            return .get
        }
    }

    var parameters: Parameters {
        switch self {
        case let .updateProfile(nickname, profileImg):
            if let profileImg = profileImg {
                return ["nickname": nickname, "profileImg": profileImg]
            } else {
                return ["nickname": nickname]
            }
        case let .myCards(lastId):
            if let lastId = lastId {
                return ["lastId": lastId]
            } else {
                return [:]
            }
        case let .otherCards(_, lastId):
            if let lastId = lastId {
                return ["lastId": lastId]
            } else {
                return [:]
            }
        case let .myFollowing(lastId):
            if let lastId = lastId {
                return ["lastId": lastId]
            } else {
                return [:]
            }
        case let .otherFollowing(_, lastId):
            if let lastId = lastId {
                return ["lastId": lastId]
            } else {
                return [:]
            }
        case let .myFollower(lastId):
            if let lastId = lastId {
                return ["lastId": lastId]
            } else {
                return [:]
            }
        case let .otherFollower(_, lastId):
            if let lastId = lastId {
                return ["lastId": lastId]
            } else {
                return [:]
            }
        case let .requestFollow(memberId):
            return ["userId": memberId]
        default:
            return [:]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .updateProfile, .requestFollow:
            return JSONEncoding.default
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
            let encoded = try encoding.encode(request, with: self.parameters)
            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}

