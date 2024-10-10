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
        }
    }

    var method: HTTPMethod {
        switch self {
        case .latestCard, .popularCard, .distancCard, .detailCard, .commentCard, .cardSummary:
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
        
        case .cardSummary:
            return [:]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .latestCard, .popularCard, .distancCard, .detailCard, .commentCard, .cardSummary:
            return URLEncoding.queryString
        }
    }

    func asURLRequest() throws -> URLRequest {

        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(self.path) {
            var request = URLRequest(url: url)
            request.method = self.method
            request.setValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjgzMDgwNTQsImV4cCI6NDgzODcwODA1NCwic3ViIjoiQWNjZXNzVG9rZW4iLCJpZCI6NjMxMTExNzU3MDY3NzMxMTAwLCJyb2xlIjoiVVNFUiJ9.bD1ktqefCL3gETkXo3Prwx5LsnkCNlxF38PMXId2VVE", forHTTPHeaderField: "Authorization")
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
