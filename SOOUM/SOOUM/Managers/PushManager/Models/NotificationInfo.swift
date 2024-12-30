//
//  NotificationInfo.swift
//  SOOUM
//
//  Created by 오현식 on 12/27/24.
//

import Foundation


class NotificationInfo {
    
    let notificationType: CommentHistoryInNoti.NotificationType?
    let targetCardId: String?
    
    init(_ info: [String: Any]) {
        let notificationType = info["notificationType"] as? String ?? ""
        self.notificationType = CommentHistoryInNoti.NotificationType(rawValue: notificationType)
        self.targetCardId = info["targetCardId"] as? String
    }
}
