//
//  AppDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 9/3/24.
//

import UIKit

import Clarity

import Firebase
import FirebaseCore
import FirebaseMessaging

import RxSwift

import CocoaLumberjack


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let provider: ManagerProviderType = ManagerProviderContainer()

    /// APNS 등록 완료 핸들러
    var registerRemoteNotificationCompletion: ((Error?) -> Void)?

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
        
        // Set log
        self.setupCocoaLumberjack()
        
        // Initalize token
        self.initializeTokenWhenFirstLaunch()
        
        // Set managers
        self.provider.initialize()
        
        FirebaseApp.configure()
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self
        
        // Initalize clarity
        let clarityConfig = ClarityConfig(projectId: Info.clarityId)
        ClaritySDK.initialize(config: clarityConfig)
        
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 계정 이관 성공 시 (런치 화면 > 온보딩 화면)으로 전환
        let userInfo = notification.request.content.userInfo
        self.setupOnboardingWhenTransferSuccessed(userInfo)
        
        var options: UNNotificationPresentationOptions
        if let isReAddedNotifications = userInfo["isReAddedNotifications"] as? Bool, isReAddedNotifications {
            options = [.list]
        } else {
            options = [.sound, .list, .banner]
        }
        completionHandler(options)
    }
    
    /// 사용자가 push notification에 대한 응답을 했을 때 실행
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo: [AnyHashable: Any] = response.notification.request.content.userInfo
        if let infoDic = userInfo as? [String: Any] {
            
            let info = NotificationInfo(infoDic)
            // 계정 이관 성공 알림일 경우 (런치 화면 > 온보딩 화면), 아닐 경우 메인 홈 탭바 화면 전환
            self.provider.pushManager.setupRootViewController(info, terminated: info.isTransfered)
        }

        completionHandler()
    }
    
    // 백그라운드 혹은 완전 종료일 때
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // 계정 이관 성공 시 (런치 화면 > 온보딩 화면)으로 전환
        self.setupOnboardingWhenTransferSuccessed(userInfo)
        
        completionHandler(.newData)
    }
}

extension AppDelegate: MessagingDelegate {
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        self.registerRemoteNotificationCompletion?(error)

        Log.error("Error registration APNS token: \(error)")
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // APN 등록 성공 후 전달받은 deviceToken을 Firebase 서버로 전달
        Messaging.messaging().apnsToken = deviceToken
        
        let current = PushTokenSet(
            apns: deviceToken,
            fcm: Messaging.messaging().fcmToken
        )
        self.provider.networkManager.registerFCMToken(with: current, #function)

        self.registerRemoteNotificationCompletion?(nil)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        let current = PushTokenSet(
            apns: messaging.apnsToken,
            fcm: fcmToken
        )
        self.provider.networkManager.registerFCMToken(with: current, #function)
    }
}

extension AppDelegate {
    
    /// CocoaLumberjack 설정
    private func setupCocoaLumberjack() {
        DDLog.add(DDOSLogger.sharedInstance) // Uses os_log

        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 1 // Always recent
        DDLog.add(fileLogger)
    }
    
    private func initializeTokenWhenFirstLaunch() {
        guard UserDefaults.isFirstLaunch else { return }
        
        // 앱 첫 실행 시 token 정보 제거
        AuthKeyChain.shared.delete(.accessToken)
        AuthKeyChain.shared.delete(.refreshToken)
    }
    
    private func setupOnboardingWhenTransferSuccessed(_ userInfo: [AnyHashable: Any]?) {
        guard let infoDic = userInfo as? [String: Any] else { return }
        
        let info = NotificationInfo(infoDic)
        if info.isTransfered {
            
            self.provider.pushManager.setupRootViewController(info, terminated: true)
        }
    }
}
