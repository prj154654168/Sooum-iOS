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
        
        let viewController = SOMDialogViewController()
        viewController.setData(
            title: "카드를 삭제할까요?",
            subTitle: "삭제한 카드는 복구할 수 없어요",
            leftAction: .init(
                mode: .cancel,
                handler: {
                    print("취소 버튼 클릭")
                }
            ),
            rightAction: .init(
                mode: .ok,
                handler: {
                    print("확인 버튼 클릭")
                }
            ),
            dimViewAction: .init(
                mode: nil,
                handler: {
                    print("딤뷰 클릭")
                }
            )
        )
        
//        let viewController = LaunchScreenViewController()
//        viewController.reactor = LaunchScreenViewReactor()
        
        window?.rootViewController = viewController
//        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}
