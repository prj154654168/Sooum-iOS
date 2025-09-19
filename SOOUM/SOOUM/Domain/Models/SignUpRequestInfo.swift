//
//  SignUpRequestInfo.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation

struct MemberInfo: Equatable {
    
    let encryptedDeviceId: String
    let deviceType: String
    let fcmToken: String
    let isNotificationAgreed: Bool
}

extension MemberInfo {
    
    init(encryptedDeviceId: String, fcmToken: String, isNotificationAgreed: Bool) {
        self.encryptedDeviceId = encryptedDeviceId
        self.deviceType = "IOS"
        self.fcmToken = fcmToken
        self.isNotificationAgreed = isNotificationAgreed
    }
}

extension MemberInfo: Encodable { }

struct Policy: Equatable {
    
    let agreedToTermsOfService: Bool
    let agreedToLocationTerms: Bool
    let agreedToPrivacyPolicy: Bool
}

extension Policy: Encodable { }
