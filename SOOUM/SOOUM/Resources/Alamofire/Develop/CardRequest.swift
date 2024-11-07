//
//  CardRequest.swift
//  SOOUM-Dev
//
//  Created by 오현식 on 9/26/24.
//

import Foundation

import Alamofire


enum CardRequest: BaseRequest {

    /// 최신순
    case latestCard(id: String?, latitude: String?, longitude: String?)
    /// 인기순
    case popularCard(latitude: String?, longitude: String?)
    /// 거리순
    case distancCard(id: String?, latitude: String, longitude: String, distanceFilter: String)
    /// 상세보기
    case detailCard(id: String, latitude: String?, longitude: String?)
    /// 상세보기 - 댓글
    case commentCard(id: String, latitude: String?, longitude: String?)
    /// 상세보기 - 댓글 좋아요 정보
    case cardSummary(id: String)
    /// 상세보기 - 카드 삭제
    case deleteCard(id: String)
    /// 상세보기 - 좋아요 업데이트
    case updateLike(id: String, isLike: Bool)
    /// 글추가
    case writeCard(
        isDistanceShared: Bool,
        latitude: String,
        longitude: String,
        isPublic: Bool,
        isStory: Bool,
        content: String,
        font: String,
        imgType: String,
        imgName: String,
        feedTags: [String]
    )
    /// 글추가 - 관련 태그 조회
    case relatedTag(keyword: String, size: Int)
    
    var path: String {
        switch self {
        case let .latestCard(id, _, _):
            if let id = id {
                return "/cards/home/latest/\(id)"
            } else {
                return "/cards/home/latest"
            }
            
        case .popularCard:
            return "/cards/home/popular"
            
        case let .distancCard(id, _, _, _):
            if let id = id {
                return "/cards/home/distance/\(id)"
            } else {
                return "/cards/home/distance"
            }
            
        case let .detailCard(id, _, _):
            return "/cards/\(id)/detail"
            
        case let .commentCard(id, _, _):
            return "/comments/current/\(id)"
            
        case let .cardSummary(id):
            return "/cards/current/\(id)/summary"
            
        case let .deleteCard(id):
            return "/cards/\(id)"
            
        case let .updateLike(id, _):
            return "/cards/\(id)/like"
            
        case .writeCard:
            return "/cards"
            
        case .relatedTag:
            return "/tags/search"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .deleteCard:
            return .delete
        case .writeCard:
            return .post
        case let .updateLike(_, isLike):
            return isLike ? .post : .delete
        default:
            return .get
        }
    }

    var parameters: Parameters {
        switch self {
        case let .latestCard(_, latitude, longitude):
            if let latitude = latitude, let longitude = longitude {
                return ["latitude": latitude, "longitude": longitude]
            } else {
                return [:]
            }
            
        case let .popularCard(latitude, longitude):
            if let latitude = latitude, let longitude = longitude {
                return ["latitude": latitude, "longitude": longitude]
            } else {
                return [:]
            }
            
        case let .distancCard(_, latitude, longitude, distanceFilter):
            return ["latitude": latitude, "longitude": longitude, "distanceFilter": distanceFilter]
            
        case let .detailCard(_, latitude, longitude):
            if let latitude = latitude, let longitude = longitude {
                return ["latitude": latitude, "longitude": longitude]
            } else {
                return [:]
            }
        
        case let .commentCard(_, latitude, longitude):
            if let latitude = latitude, let longitude = longitude {
                return ["latitude": latitude, "longitude": longitude]
            } else {
                return [:]
            }
            
        case let .writeCard(
            isDistanceShared,
            latitude,
            longitude,
            isPublic,
            isStory,
            content,
            font,
            imgType,
            imgName,
            feedTags
        ):
            if isDistanceShared {
                return [
                    "isDistanceShared": true,
                    "latitude": latitude,
                    "longitude": longitude,
                    "isPublic": isPublic,
                    "isStory": isStory,
                    "content": content,
                    "font": font,
                    "imgType": imgType,
                    "imgName": imgName,
                    "feedTags": feedTags
                ]
            } else {
                return [
                    "isDistanceShared": false,
                    "isPublic": isPublic,
                    "isStory": isStory,
                    "content": content,
                    "font": font,
                    "imgType": imgType,
                    "imgName": imgName,
                    "feedTags": feedTags
                ]
            }
            
        case let .relatedTag(keyword, size):
            return ["keyword": keyword, "size": size]
        
        default:
            return [:]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .updateLike, .writeCard:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
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

            let encoded = try encoding.encode(request, with: self.parameters)
            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}
