//
//  AppRoute.swift
//  SOOUM
//
//  Created by Codex on 7/5/26.
//

import Foundation

enum AppRoute: Hashable {
    case launch(pushInfo: PushNotificationInfo? = nil)
    case onboarding
    case mainTab(pushInfo: PushNotificationInfo? = nil)
}
