//
//  AppDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 9/3/24.
//

import UIKit

import Firebase
import FirebaseCore
import FirebaseMessaging

import RxSwift

import CocoaLumberjack


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let authManager = AuthManager.shared

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
        
        FirebaseApp.configure()
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self
        // 앱 알림 설정을 위한 초기화
        _ = PushManager.init()
        
        // 앱 첫 실행 시 할 일
        self.todoFirstLaunch()
        
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
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        
        let options: UNNotificationPresentationOptions = [.sound, .list, .banner]
        completionHandler(options)
    }
    
    /// 사용자가 push notification에 대한 응답을 했을 때 실행할 코드 작성
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo: [AnyHashable: Any] = response.notification.request.content.userInfo

        if let messageID: String = userInfo["gcm.message_id"] as? String {
            Log.info("Message ID: \(messageID)")
        }
        
        if let infoDic = userInfo as? [String: Any] {
            
            let info = NotificationInfo(infoDic)
            PushManager.shared.setupRootViewController(info, terminated: false)
        }

        completionHandler()
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
        self.authManager.updateFcmToken(with: current, call: #function)
        
        Log.info("Call func: \(#function)")

        self.registerRemoteNotificationCompletion?(nil)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        let current = PushTokenSet(
            apns: messaging.apnsToken,
            fcm: fcmToken
        )
        self.authManager.updateFcmToken(with: current, call: #function)
        
        Log.info("Call func: \(#function)")
    }
}

extension AppDelegate {
    
    /// CocoaLumberjack 설정
    private func setupCocoaLumberjack() {
        DDLog.add(DDOSLogger.sharedInstance) // Uses os_log

        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
    private func todoFirstLaunch() {
        
        guard UserDefaults.isFirstLaunch else { return }
        
        // 앱 첫 실행 시 fcm token 요청 (회원가입 필수)
        UIApplication.shared.registerForRemoteNotifications()
        
        // 앱 첫 실행 시 token 정보 제거
        AuthKeyChain.shared.delete(.accessToken)
        AuthKeyChain.shared.delete(.refreshToken)
    }
}
