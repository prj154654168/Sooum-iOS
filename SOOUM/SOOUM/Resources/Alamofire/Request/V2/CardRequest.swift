//
//  CardRequest.swift
//  SOOUM-Dev
//
//  Created by 오현식 on 9/26/24.
//

import Foundation

import Alamofire


enum CardRequest: BaseRequest {

    
    // MARK: Home
    
    /// 최신순
    case latestCard(lastId: String?, latitude: String?, longitude: String?)
    /// 인기순
    case popularCard(latitude: String?, longitude: String?)
    /// 거리순
    case distancCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String)
    
    
    // MARK: Detail
    
    case detailCard(id: String, latitude: String?, longitude: String?)
    /// 상세보기 - 답카드
    case commentCard(id: String, lastId: String?, latitude: String?, longitude: String?)
    /// 상세보기 - 답카드 좋아요 정보
    case cardSummary(id: String)
    /// 상세보기 - 카드 삭제
    case deleteCard(id: String)
    /// 상세보기 - 좋아요 업데이트
    case updateLike(id: String, isLike: Bool)
    
    
    // MARK: Write
    
    /// 기본 이미지 조회
    case defaultImages
    /// 글추가
    case writeCard(
        isDistanceShared: Bool,
        latitude: String?,
        longitude: String?,
        content: String,
        font: String,
        imgType: String,
        imgName: String,
        isStory: Bool,
        tags: [String]?
    )
    /// 답카드 추가
    case writeComment(
        id: String,
        isDistanceShared: Bool,
        latitude: String,
        longitude: String,
        content: String,
        font: String,
        imgType: String,
        imgName: String,
        commentTags: [String]
    )
    /// 글추가 - 관련 태그 조회
    case relatedTag(keyword: String, size: Int)
    
    var path: String {
        switch self {
        case let .latestCard(lastId, _, _):
            if let lastId = lastId {
                return "/api/cards/feeds/latest/\(lastId)"
            } else {
                return "/api/cards/feeds/latest"
            }
            
        case .popularCard:
            return "/api/cards/feeds/popular"
            
        case let .distancCard(lastId, _, _, _):
            if let lastId = lastId{
                return "/api/cards/feeds/distance/\(lastId)"
            } else {
                return "/api/cards/feeds/distance"
            }
            
        case let .detailCard(id, _, _):
            return "/cards/\(id)/detail"
            
        case let .commentCard(id, _, _, _):
            return "/comments/current/\(id)"
            
        case let .cardSummary(id):
            return "/cards/current/\(id)/summary"
            
        case let .deleteCard(id):
            return "/cards/\(id)"
            
        case let .updateLike(id, _):
            return "/cards/\(id)/like"
            
            
        case .defaultImages:
            return "/images/defaults"
        case .writeCard:
            return "/cards"
            
        case let .writeComment(id, _, _, _, _, _, _, _, _):
            return "/cards/\(id)"
            
        case .relatedTag:
            return "/tags/search"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .deleteCard:
            return .delete
        case .writeCard, .writeComment:
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
            return ["latitude": latitude, "longitude": longitude, "distance": distanceFilter]
            
        case let .detailCard(_, latitude, longitude):
            if let latitude = latitude, let longitude = longitude {
                return ["latitude": latitude, "longitude": longitude]
            } else {
                return [:]
            }
        
        case let .commentCard(_, lastId, latitude, longitude):
            var params: Parameters = [:]
            if let lastId = lastId {
                params.updateValue(lastId, forKey: "lastId")
            }
            if let latitude = latitude, let longitude = longitude {
                params.updateValue(latitude, forKey: "latitude")
                params.updateValue(longitude, forKey: "longitude")
            }
            return params
            
        case let .writeCard(
            isDistanceShared,
            latitude,
            longitude,
            content,
            font,
            imgType,
            imgName,
            isStory,
            tags
        ):
            var parameters: [String: Any] = [
                "isDistanceShared": isDistanceShared,
                "content": content,
                "font": font,
                "imgType": imgType,
                "imgName": imgName,
                "isStory": isStory
            ]
            
            if isDistanceShared, let latitude = latitude, let longitude = longitude {
                parameters.updateValue(latitude, forKey: "latitude")
                parameters.updateValue(longitude, forKey: "longitude")
            }
            
            if isStory == false, let tags = tags {
                parameters.updateValue(tags, forKey: "tags")
            }
            
            return parameters
            
        case let .writeComment(
            _,
            isDistanceShared,
            latitude,
            longitude,
            content,
            font,
            imgType,
            imgName,
            commentTags
        ):
            var parameters: [String: Any] = [
                "isDistanceShared": isDistanceShared,
                "content": content,
                "font": font,
                "imgType": imgType,
                "imgName": imgName,
            ]
            
            if isDistanceShared {
                parameters.updateValue(latitude, forKey: "latitude")
                parameters.updateValue(longitude, forKey: "longitude")
            }
            
            if commentTags.isEmpty == false {
                parameters.updateValue(commentTags, forKey: "commentTags")
            }
            
            return parameters
            
        case let .relatedTag(keyword, size):
            return ["keyword": keyword, "size": size]
        
        default:
            return [:]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .updateLike, .writeCard, .writeComment:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
    
    var authorizationType: AuthorizationType {
        return .access
    }

    func asURLRequest() throws -> URLRequest {

        let pathWithAPIVersion = self.path
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

            let encoded = try encoding.encode(request, with: self.parameters)
            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}
