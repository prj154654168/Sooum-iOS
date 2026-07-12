//
//  MainTabCoordinator.swift
//  SOOUM
//
//  Created by Codex on 7/5/26.
//

import UIKit

final class MainTabCoordinator: BaseCoordinator {

    private let window: UIWindow
    private let factory: ScreenFactory
    private let pushInfo: PushNotificationInfo?

    init(
        window: UIWindow,
        factory: ScreenFactory,
        pushInfo: PushNotificationInfo?
    ) {
        self.window = window
        self.factory = factory
        self.pushInfo = pushInfo
    }

    override func start() {
        self.window.rootViewController = self.factory.makeMainTabRoot(pushInfo: self.pushInfo)
        self.window.makeKeyAndVisible()
    }
}
