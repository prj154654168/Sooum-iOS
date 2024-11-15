//
//  AppDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 9/3/24.
//

import UIKit

import RxSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // RxSwift Resource count
        #if DEBUG
        _ = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                print("Resource count \(RxSwift.Resources.total)")
            })
        #endif
        
        return true
    }

    
    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) { }
}
