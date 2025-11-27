//
//  NotificationInfo.swift
//  SOOUM
//
//  Created by 오현식 on 12/27/24.
//

import Foundation

class PushNotificationInfo {
    
    let notificationType: CommonNotificationInfo.NotificationType
    let notificationId: String?
    let targetCardId: String?
    
    var isTransfered: Bool {
        return self.notificationType == .transferSuccess
    }
    
    init(_ info: [String: Any]) {
        let notificationType = info["notificationType"] as? String ?? ""
        self.notificationType = CommonNotificationInfo.NotificationType(rawValue: notificationType) ?? .none
        self.notificationId = info["notificationId"] as? String
        self.targetCardId = info["targetCardId"] as? String
    }
}
