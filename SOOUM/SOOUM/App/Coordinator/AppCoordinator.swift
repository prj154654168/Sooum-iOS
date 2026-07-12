//
//  AppCoordinator.swift
//  SOOUM
//
//  Created by Codex on 7/5/26.
//

import UIKit

final class AppCoordinator: BaseCoordinator {

    private let window: UIWindow
    private let factory: ScreenFactory
    private var currentRoute: AppRoute?

    init(
        window: UIWindow,
        factory: ScreenFactory
    ) {
        self.window = window
        self.factory = factory
    }

    override func start() {
        self.start(initialRoute: .launch())
    }

    func start(initialRoute: AppRoute) {
        self.handle(initialRoute)
    }

    func handle(_ route: AppRoute) {
        // 같은 루트 전환이 연속으로 들어오면 새 화면도 즉시 교체될 수 있어 중복 처리를 막는다.
        guard self.currentRoute != route else { return }
        self.currentRoute = route

        switch route {
        case let .launch(pushInfo):
            self.childCoordinators.removeAll()
            self.showRootViewController(
                self.factory.makeLaunchRoot(pushInfo: pushInfo)
            )

        case .onboarding:
            self.childCoordinators.removeAll()
            self.showRootViewController(self.factory.makeOnboardingRoot())

        case let .mainTab(pushInfo):
            let coordinator = MainTabCoordinator(
                window: self.window,
                factory: self.factory,
                pushInfo: pushInfo
            )
            self.childCoordinators.removeAll { $0 is MainTabCoordinator }
            self.store(coordinator)
            coordinator.start()
        }
    }

    private func showRootViewController(_ viewController: UIViewController) {
        self.window.rootViewController = viewController
        self.window.makeKeyAndVisible()
    }
}
