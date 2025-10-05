//
//  CompositeNotificationInfo.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/25.
//

import Foundation

enum CompositeNotificationInfo: Hashable, Equatable {
    case `default`(NotificationInfoResponse)
    case follow(FollowNotificationInfoResponse)
    case deleted(DeletedNotificationInfoResponse)
    case blocked(BlockedNotificationInfoResponse)
}

extension CompositeNotificationInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case notificationType
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let notificationType = try container.decode(CommonNotificationInfo.NotificationType.self, forKey: .notificationType)
        
        switch notificationType {
        case .follow:
            let notification = try FollowNotificationInfoResponse(from: decoder)
            self = .follow(notification)
        case .deleted:
            let notification = try DeletedNotificationInfoResponse(from: decoder)
            self = .deleted(notification)
        case .blocked:
            let notification = try BlockedNotificationInfoResponse(from: decoder)
            self = .blocked(notification)
        case .feedLike, .commentLike, .commentWrite:
            let notification = try NotificationInfoResponse(from: decoder)
            self = .default(notification)
        // TODO: NOTICE, TRANSFER_SUCCESS 는 아직 정해지지 않음
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported notification type"
                )
            )
        }
    }
}
