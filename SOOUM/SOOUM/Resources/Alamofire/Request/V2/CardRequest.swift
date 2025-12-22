//
//  CardRequest.swift
//  SOOUM-Dev
//
//  Created by 오현식 on 9/26/24.
//

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
    
    /// 상세보기
    case detailCard(id: String, latitude: String?, longitude: String?)
    /// 상세보기 - 삭제 여부
    case isCardDeleted(id: String)
    /// 상세보기 - 답카드
    case commentCard(id: String, lastId: String?, latitude: String?, longitude: String?)
    /// 상세보기 - 카드 삭제
    case deleteCard(id: String)
    /// 상세보기 - 좋아요 업데이트
    case updateLike(id: String, isLike: Bool)
    /// 상세보기 - 신고
    case reportCard(id: String, reportType: String)
    
    // MARK: Write
    
    /// 기본 이미지 조회
    case defaultImages
    /// 프로필 이미지 업로드할 공간 조회
    case presignedURL
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
        tags: [String]
    )
    /// 답카드 추가
    case writeComment(
        id: String,
        isDistanceShared: Bool,
        latitude: String?,
        longitude: String?,
        content: String,
        font: String,
        imgType: String,
        imgName: String,
        tags: [String]
    )
    
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
            return "/api/cards/\(id)"
            
        case let .commentCard(id, lastId, _, _):
            
            if let lastId = lastId {
                return "/api/cards/\(id)/comments/\(lastId)"
            } else {
                return "/api/cards/\(id)/comments"
            }
        case let .deleteCard(id):
            
            return "/api/cards/\(id)"
        case let .isCardDeleted(id):
            
            return "/api/cards/\(id)/delete-check"
        case let .updateLike(id, _):
            
            return "/api/cards/\(id)/like"
        case let .reportCard(id, _):
            
            return "/api/reports/cards/\(id)"
        case .defaultImages:
            
            return "/api/images/defaults"
        case .presignedURL:
            
            return "/api/images/card-img"
        case .writeCard:
            
            return "/api/cards"
        case let .writeComment(id, _, _, _, _, _, _, _, _):
            
            return "/api/cards/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .deleteCard:
            return .delete
        case .reportCard, .writeCard, .writeComment:
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
        case let .commentCard(_, _, latitude, longitude):
            
            if let latitude = latitude, let longitude = longitude {
                return ["latitude": latitude, "longitude": longitude]
            } else {
                return [:]
            }
        case let .reportCard(_, reportType):
            
            return ["reportType": reportType]
            
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
                "isStory": isStory,
                "tags": tags
            ]
            
            if isDistanceShared, let latitude = latitude, let longitude = longitude {
                parameters.updateValue(latitude, forKey: "latitude")
                parameters.updateValue(longitude, forKey: "longitude")
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
            tags
        ):
            
            var parameters: [String: Any] = [
                "isDistanceShared": isDistanceShared,
                "content": content,
                "font": font,
                "imgType": imgType,
                "imgName": imgName,
                "tags": tags
            ]
            
            if isDistanceShared, let latitude = latitude, let longitude = longitude {
                parameters.updateValue(latitude, forKey: "latitude")
                parameters.updateValue(longitude, forKey: "longitude")
            }
            
            return parameters
        default:
            return [:]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .reportCard, .writeCard, .writeComment:
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
