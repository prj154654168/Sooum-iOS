//
//  SceneDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 9/3/24.
//

import UIKit

import Kingfisher


class SceneDelegate: UIResponder, UIWindowSceneDelegate, SceneRouteHandling {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    private var routeStore: AppRouteStore?
    private(set) var canHandleRoutes: Bool = false
    private var hasCompletedInitialRouting: Bool = false


    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        self.window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        self.window?.windowScene = windowScene

        guard let window = self.window else { return }

        let coordinator = AppCoordinator(
            window: window,
            factory: DefaultScreenFactory(dependencies: appDelegate.appDIContainer)
        )
        self.appCoordinator = coordinator
        self.routeStore = appDelegate.appDIContainer.rootContainer.resolve(AppRouteStore.self)
        self.routeStore?.setActiveSceneHandler(self)

        window.backgroundColor = .white
        
        let initialRoute: AppRoute
        /// 앱이 완전히 종료되었을 때 push notification에 대한 응답을 했을 때 실행할 코드 작성
        if let response: UNNotificationResponse = connectionOptions.notificationResponse {
            let userInfo: [AnyHashable: Any] = response.notification.request.content.userInfo
            if let infoDic = userInfo as? [String: Any] {
                let info = PushNotificationInfo(infoDic)
                initialRoute = .launch(pushInfo: info)
            } else {
                initialRoute = .launch()
            }
        } else {
            initialRoute = .launch()
        }

        coordinator.start(initialRoute: initialRoute)
        self.hasCompletedInitialRouting = true

        if let pendingRoute = self.routeStore?.consumePendingRoute(),
           pendingRoute != initialRoute {
            coordinator.handle(pendingRoute)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        self.canHandleRoutes = true
        self.routeStore?.setActiveSceneHandler(self)

        guard self.hasCompletedInitialRouting,
              let pendingRoute = self.routeStore?.consumePendingRoute()
        else { return }

        self.handle(pendingRoute)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        self.canHandleRoutes = false
        self.routeStore?.clearActiveSceneHandler(self)
    }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) {
        self.canHandleRoutes = false
        self.routeStore?.clearActiveSceneHandler(self)
        // 앱이 백그라운드 상태로 전환 되면, 모든 캐시 삭제
        Kingfisher.ImageCache.default.clearCache()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        self.canHandleRoutes = false
        self.routeStore?.clearActiveSceneHandler(self)
        // 앱이 완전히 종료되었을 때, 모든 캐시 삭제
        Kingfisher.ImageCache.default.clearCache()
    }

    func handle(_ route: AppRoute) {
        self.appCoordinator?.handle(route)
    }
}
