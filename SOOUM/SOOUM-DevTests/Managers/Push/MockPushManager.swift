//
//  MockPushManager.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/2/25.
//

@testable import SOOUM_Dev

import UIKit


class MockPushManager: CompositeManager<PushManagerConfiguration>, PushManagerDelegate {
    
    var notiInfo: NotificationInfo?
    
    var window: UIWindow? = .init(frame: .zero)
    
    var canReceiveNotifications: Bool = true
    var notificationStatus: Bool = true
    
    func setupRootViewController(_ info: NotificationInfo?, terminated: Bool) {
        self.notiInfo = info
    }
    
    func switchNotification(isOn: Bool, completion: (((any Error)?) -> Void)?) {
        self.notificationStatus = isOn && self.canReceiveNotifications
        completion?(nil)
    }
}
