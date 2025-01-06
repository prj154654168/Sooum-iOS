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


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    enum Text {
        static let updateVerionTitle: String = "업데이트 안내"
        static let updateVersionMessage: String = "안정적인 서비스 사용을 위해\n최신버전으로 업데이트해주세요"
        
        static let testFlightStrUrl: String = "itms-beta://apps.apple.com/app/id"
    }
    
    private let authManager = AuthManager.shared
    private let disposeBag = DisposeBag()

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
        
        FirebaseApp.configure()
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self
        // 앱 알림 설정을 위한 초기화
        _ = PushManager.init()
        
        // 앱 첫 실행 시 token 정보 제거
        self.removeKeyChainWhenFirstLaunch()
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.checkUpdate()
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
            print("Message ID: \(messageID)")
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

        print("❌ Error registration APNS token: \(error)")
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
        self.authManager.registeredToken = current
        
        print("ℹ️ Call func: \(#function)")

        self.registerRemoteNotificationCompletion?(nil)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        let current = PushTokenSet(
            apns: messaging.apnsToken,
            fcm: fcmToken
        )
        self.authManager.registeredToken = current
        
        print("ℹ️ Call func: \(#function)")
    }
}

extension AppDelegate {
    
    private func removeKeyChainWhenFirstLaunch() {
        
        guard UserDefaults.isFirstLaunch else { return }
        AuthKeyChain.shared.delete(.accessToken)
        AuthKeyChain.shared.delete(.refreshToken)
    }
}

extension AppDelegate {
    
    func checkUpdate() {
        
        NetworkManager.shared.checkClientVersion()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, currentVersion in
                
                let model = Version(currentVerion: currentVersion)
                if model.mustUpdate {
                    
                    SOMDialogViewController.show(
                        title: Text.updateVerionTitle,
                        subTitle: Text.updateVersionMessage,
                        leftAction: .init(
                            mode: .exit,
                            handler: {
                                // 앱 종료
                                // 자연스럽게 종료하기 위해 종료전, suspend 상태로 변경 후 종료
                                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    exit(0)
                                }
                            }
                        ),
                        rightAction: .init(
                            mode: .update,
                            handler: {
                                #if DEVELOP
                                // 개발 버전일 때 testFlight로 전환
                                let strUrl = "\(Text.testFlightStrUrl)\(Info.appId)"
                                if let testFlightUrl = URL(string: strUrl) {
                                    UIApplication.shared.open(testFlightUrl, options: [:], completionHandler: nil)
                                }
                                #endif
                                
                                UIApplication.topViewController?.dismiss(animated: true)
                            }
                        )
                    )
                }
            }
            .disposed(by: self.disposeBag)
    }
}
