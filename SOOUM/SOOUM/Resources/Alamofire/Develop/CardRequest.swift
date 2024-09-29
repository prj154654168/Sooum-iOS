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
        }
    }

    var method: HTTPMethod {
        switch self {
        case .latestCard, .popularCard, .distancCard:
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
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .latestCard, .popularCard, .distancCard:
            return URLEncoding.queryString
        }
    }

    func asURLRequest() throws -> URLRequest {

        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(self.path) {
            var request = URLRequest(url: url)
            request.method = self.method
            request.setValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjY5Mjk0MzMsImV4cCI6MTAxNzI2OTI5NDMzLCJzdWIiOiJBY2Nlc3NUb2tlbiIsImlkIjo2MjUwNDc5NzMyNTA1MTUxNTMsInJvbGUiOiJVU0VSIn0.aL4Tr3FaSwvu9hOQISAvGJfCHBGCV9jRo_BfTQkBssU", forHTTPHeaderField: "Authorization")
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
