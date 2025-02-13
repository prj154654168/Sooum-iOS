//
//  NotificationInfo.swift
//  SOOUM
//
//  Created by 오현식 on 12/27/24.
//

import Foundation


class NotificationInfo {
    
    let notificationType: CommentHistoryInNoti.NotificationType?
    let notificationId: String?
    let targetCardId: String?
    
    var isTransfered: Bool {
        return self.notificationType == .transfer
    }
    
    init(_ info: [String: Any]) {
        let notificationType = info["notificationType"] as? String ?? ""
        self.notificationType = CommentHistoryInNoti.NotificationType(rawValue: notificationType)
        self.notificationId = info["notificationId"] as? String
        self.targetCardId = info["targetCardId"] as? String
    }
}
