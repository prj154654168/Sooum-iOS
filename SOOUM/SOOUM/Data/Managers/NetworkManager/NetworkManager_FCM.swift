//
//  NetworkManager_FCM.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation

import Alamofire
import FirebaseMessaging
import RxSwift


// MARK: Register FCM token

extension NetworkManager {
    
    static var registeredToken: PushTokenSet?
    static var cachedAPNSToken: Data?
    static var cachedFCMToken: String?
    static var pendingRegistration: Bool = false
    static var isRegisteringFCMToken: Bool = false
    static let fcmQueue = DispatchQueue(label: "com.sooum.network.fcm.queue")
    static var fcmDisposeBag = DisposeBag()
    
    func registerFCMToken(with tokenSet: PushTokenSet, _ function: String) {
        Self.fcmQueue.async { [weak self] in
            guard let self else { return }
            
            if let apns = tokenSet.apns {
                Self.cachedAPNSToken = apns
            }
            if let fcm = tokenSet.fcm {
                Self.cachedFCMToken = fcm
            }
            
            Self.pendingRegistration = true
            self.registerFCMTokenIfPossible(from: function)
        }
    }
    
    private func registerFCMTokenIfPossible(from function: String) {
        guard Self.isRegisteringFCMToken == false else { return }
        
        // AccessToken이 없는 경우 업데이트에 실패하므로 무시
        guard self.provider.authManager.hasToken else {
            Log.info("Can't upload fcm token without authorization token. (from: \(function))")
            return
        }
        
        let tokenSet = PushTokenSet(
            apns: Self.cachedAPNSToken ?? Messaging.messaging().apnsToken,
            fcm: Self.cachedFCMToken ?? Messaging.messaging().fcmToken
        )
        
        guard let fcmToken = tokenSet.fcm, let apns = tokenSet.apns else {
            Log.info("FCM registration is pending until both APNS and FCM tokens are ready. (from: \(function))")
            return
        }
        
        Self.cachedAPNSToken = apns
        Self.cachedFCMToken = fcmToken
        Self.isRegisteringFCMToken = true
        Self.pendingRegistration = false
        
        Log.info("Firebase registration token: \(fcmToken) [with \(apns)] (from: \(function))")
        
        let request: UserRequest = .updateFCMToken(fcmToken: fcmToken)
        self.perform(request)
            .subscribe(
                onNext: { [weak self] _ in
                    Self.fcmQueue.async {
                        Self.registeredToken = tokenSet
                        Self.isRegisteringFCMToken = false
                        
                        guard Self.pendingRegistration else { return }
                        self?.registerFCMTokenIfPossible(from: function)
                    }
                    Log.info("Update FCM token to server with", fcmToken)
                },
                onError: { [weak self] _ in
                    Self.fcmQueue.async {
                        Self.pendingRegistration = true
                        Self.isRegisteringFCMToken = false
                        self?.registerFCMTokenIfPossible(from: function)
                    }
                    Log.error("Failed to update FCM token to server: not found user")
                }
            )
            .disposed(by: Self.fcmDisposeBag)
    }
    
    func registerFCMToken(from func: String) {
        Self.fcmQueue.async { [weak self] in
            guard let self else { return }
            
            if let apns = Messaging.messaging().apnsToken {
                Self.cachedAPNSToken = apns
            }
            if let fcmToken = Messaging.messaging().fcmToken {
                Self.cachedFCMToken = fcmToken
            }
            
            Self.pendingRegistration = true
            self.registerFCMTokenIfPossible(from: `func`)
        }
    }
}
