//
//  SceneDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 9/3/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        let viewController = LaunchScreenViewController()
        viewController.reactor = LaunchScreenViewReactor()

        window?.rootViewController = viewController
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        /// 앱이 완전히 종료되었을 때 push notification에 대한 응답을 했을 때 실행할 코드 작성
        if let response: UNNotificationResponse = connectionOptions.notificationResponse {
            let userInfo: [AnyHashable: Any] = response.notification.request.content.userInfo

            if let infoDic: [String: Any] = userInfo as? [String: Any] {
                
                let info = NotificationInfo(infoDic)
                PushManager.shared.setupRootViewController(info, terminated: true)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}
