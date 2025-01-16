//
//  NotificationRequest.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import Foundation

import Alamofire


enum NotificationRequest: BaseRequest {
    
    case totalWithoutRead(lastId: String?)
    case totalRead(lastId: String?)
    case totalWithoutReadCount
    case commentWithoutRead(lastId: String?)
    case commentRead(lastId: String?)
    case commentWithoutReadCount
    case likeWithoutRead(lastId: String?)
    case likeRead(lastId: String?)
    case likeWihoutReadCount
    
    case requestRead(notificationId: String)
    
    var path: String {
        switch self {
        case let .totalWithoutRead(lastId):
            if let lastId = lastId {
                return "/notifications/unread/\(lastId)"
            } else {
                return "/notifications/unread"
            }
        case let .totalRead(lastId):
            if let lastId = lastId {
                return "/notifications/read/\(lastId)"
            } else {
                return "/notifications/read"
            }
        case .totalWithoutReadCount:
            return "/notifications/unread-cnt"
        case let .commentWithoutRead(lastId):
            if let lastId = lastId {
                return "/notifications/card/unread/\(lastId)"
            } else {
                return "/notifications/card/unread"
            }
        case let .commentRead(lastId):
            if let lastId = lastId {
                return "/notifications/card/read/\(lastId)"
            } else {
                return "/notifications/card/read"
            }
        case .commentWithoutReadCount:
            return "/notifications/card/unread-cnt"
        case let .likeWithoutRead(lastId):
            if let lastId = lastId {
                return "/notifications/like/unread/\(lastId)"
            } else {
                return "/notifications/like/unread"
            }
        case let .likeRead(lastId):
            if let lastId = lastId {
                return "/notifications/like/read/\(lastId)"
            } else {
                return "/notifications/like/read"
            }
        case .likeWihoutReadCount:
            return "/notifications/like/unread-cnt"
        case let .requestRead(notificationId):
            return "/notifications/\(notificationId)/read"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .requestRead:
            return .patch
        default:
            return .get
        }
    }
    
    var parameters: Parameters {
        return [:]
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
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
