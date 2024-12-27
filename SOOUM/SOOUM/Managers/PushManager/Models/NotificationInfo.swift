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
        self.notificationType = info["notificationType"] as? CommentHistoryInNoti.NotificationType
        self.targetCardId = info["targetCardId"] as? String
    }
}
