//
//  NotificationRequest.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import Alamofire


enum NotificationRequest: BaseRequest {
    
    /// 읽지 않은 알림 전체 조회
    case unreadNotifications(lastId: String?)
    /// 읽지 않은 카드 알림 조회
    case unreadCardNotifications(lastId: String?)
    /// 읽지 않은 팔로우 알림 조회
    case unreadFollowNotifications(lastId: String?)
    /// 읽지 않은 공지 알림 조회
    case unreadNoticeNoticeNotifications(lastId: String?)
    /// 읽은 알림 전체 조회
    case readNotifications(lastId: String?)
    /// 읽은 카드 알림 조회
    case readCardNotifications(lastId: String?)
    /// 읽은 팔로우 알림 조회
    case readFollowNotifications(lastId: String?)
    /// 읽은 공지 알림 조회
    case readNoticeNoticeNotifications(lastId: String?)
    /// 알림 읽음 요청
    case requestRead(notificationId: String)
    
    var path: String {
        switch self {
        case let .unreadNotifications(lastId):
            if let lastId = lastId {
                return "/api/notifications/unread/\(lastId)"
            } else {
                return "/api/notifications/unread"
            }
            
        case let .unreadCardNotifications(lastId):
            if let lastId = lastId {
                return "/api/notifications/unread/card/\(lastId)"
            } else {
                return "/api/notifications/unread/card"
            }
            
        case let .unreadFollowNotifications(lastId):
            if let lastId = lastId {
                return "/api/notifications/unread/follow/\(lastId)"
            } else {
                return "/api/notifications/unread/follow"
            }
            
        case let .unreadNoticeNoticeNotifications(lastId):
            if let lastId = lastId {
                return "/api/notifications/unread/notice/\(lastId)"
            } else {
                return "/api/notifications/unread/notice"
            }
            
        case let .readNotifications(lastId):
            if let lastId = lastId {
                return "/api/notifications/read/\(lastId)"
            } else {
                return "/api/notifications/read"
            }
            
        case let .readCardNotifications(lastId):
            if let lastId = lastId {
                return "/api/notifications/read/card/\(lastId)"
            } else {
                return "/api/notifications/read/card"
            }
            
        case let .readFollowNotifications(lastId):
            if let lastId = lastId {
                return "/api/notifications/read/follow/\(lastId)"
            } else {
                return "/api/notifications/read/follow"
            }
            
        case let .readNoticeNoticeNotifications(lastId):
            if let lastId = lastId {
                return "/api/notifications/read/notice/\(lastId)"
            } else {
                return "/api/notifications/read/notice"
            }
            
        case let .requestRead(notificationId):
            return "/api/notifications/\(notificationId)/read"
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
            return .init(url: URL(string: "")!)
        }
    }
}
