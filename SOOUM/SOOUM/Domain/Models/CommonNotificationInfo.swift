//
//  NotificationInfo.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation

struct CommonNotificationInfo: Hashable, Equatable {
    
    let notificationId: String
    let notificationType: NotificationType
    let createTime: Date
}

extension CommonNotificationInfo {
    
    static var defaultValue: CommonNotificationInfo = CommonNotificationInfo(
        notificationId: "",
        notificationType: .none,
        createTime: Date()
    )
}

extension CommonNotificationInfo {
    
    enum NotificationType: String {
        
        case feedLike = "FEED_LIKE"
        case commentLike = "COMMENT_LIKE"
        case commentWrite = "COMMENT_WRITE"
        case blocked = "BLOCKED"
        case deleted = "DELETED"
        case transferSuccess = "TRANSFER_SUCCESS"
        case follow = "FOLLOW"
        case notice = "NOTICE"
        case none = "NONE"
    }
}

extension CommonNotificationInfo.NotificationType: Decodable { }
extension CommonNotificationInfo: Decodable {
    
    enum CodingKeys: CodingKey {
        case notificationId
        case notificationType
        case createTime
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.notificationId = String(try container.decode(Int.self, forKey: .notificationId))
        self.notificationType = try container.decode(CommonNotificationInfo.NotificationType.self, forKey: .notificationType)
        self.createTime = try container.decode(Date.self, forKey: .createTime)
    }
}
