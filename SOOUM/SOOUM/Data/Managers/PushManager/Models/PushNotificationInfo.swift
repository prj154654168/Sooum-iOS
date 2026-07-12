//
//  NotificationInfo.swift
//  SOOUM
//
//  Created by 오현식 on 12/27/24.
//

import Foundation

final class PushNotificationInfo {
    
    let notificationType: CommonNotificationInfo.NotificationType
    let notificationId: String?
    let targetCardId: String?
    let imageURL: String?
    
    var isTransfered: Bool {
        return self.notificationType == .transferSuccess
    }
    
    init(_ info: [String: Any]) {
        let notificationType = info["notificationType"] as? String ?? ""
        self.notificationType = CommonNotificationInfo.NotificationType(rawValue: notificationType) ?? .none
        self.notificationId = info["notificationId"] as? String
        self.targetCardId = info["targetCardId"] as? String
        self.imageURL = info["imageUrl"] as? String
        
        Log.info(
            """
            PushNotificationInfo:
                notificationType: \(self.notificationType)
                notificationId: \(self.notificationId ?? "Nil")
                targetCardId: \(self.targetCardId ?? "Nil")
                imageURL: \(self.imageURL ?? "Nil")
            """
        )
    }
}

extension PushNotificationInfo: Hashable {
    
    static func == (lhs: PushNotificationInfo, rhs: PushNotificationInfo) -> Bool {
        lhs.notificationType == rhs.notificationType &&
        lhs.notificationId == rhs.notificationId &&
        lhs.targetCardId == rhs.targetCardId &&
        lhs.imageURL == rhs.imageURL
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.notificationType)
        hasher.combine(self.notificationId)
        hasher.combine(self.targetCardId)
        hasher.combine(self.imageURL)
    }
}
