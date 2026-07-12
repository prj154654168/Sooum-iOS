//
//  ScreenFactory.swift
//  SOOUM
//
//  Created by Codex on 7/5/26.
//

import UIKit

protocol ScreenFactory {
    func makeLaunchRoot(pushInfo: PushNotificationInfo?) -> UIViewController
    func makeOnboardingRoot() -> UIViewController
    func makeMainTabRoot(pushInfo: PushNotificationInfo?) -> UIViewController
}

final class DefaultScreenFactory: ScreenFactory {

    private let dependencies: AppDIContainerable
    
    private var appRouter: AppRouting {
        self.dependencies.rootContainer.resolve(AppRouting.self)
    }

    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
    }

    func makeLaunchRoot(pushInfo: PushNotificationInfo?) -> UIViewController {
        let viewController = LaunchScreenViewController(appRouter: self.appRouter)
        viewController.reactor = LaunchScreenViewReactor(
            dependencies: self.dependencies,
            pushInfo: pushInfo
        )
        viewController.modalTransitionStyle = .crossDissolve
        return UINavigationController(rootViewController: viewController)
    }

    func makeOnboardingRoot() -> UIViewController {
        let viewController = OnboardingViewController()
        viewController.reactor = OnboardingViewReactor(dependencies: self.dependencies)
        viewController.modalTransitionStyle = .crossDissolve
        return UINavigationController(rootViewController: viewController)
    }

    func makeMainTabRoot(pushInfo: PushNotificationInfo?) -> UIViewController {
        let viewController = MainTabBarController(appRouter: self.appRouter)
        viewController.reactor = MainTabBarReactor(
            dependencies: self.dependencies,
            pushInfo: pushInfo
        )
        viewController.modalTransitionStyle = .crossDissolve
        return UINavigationController(rootViewController: viewController)
    }
}
