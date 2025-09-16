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
    static var fcmDisposeBag = DisposeBag()
    
    func registerFCMToken(with tokenSet: PushTokenSet, _ function: String) {
        
        // AccessToken이 없는 경우 업데이트에 실패하므로 무시
        guard let provider = self.provider, provider.authManager.hasToken else {
            Log.info("Can't upload fcm token without authorization token. (from: \(function))")
            return
        }
        
        
        let prevTokenSet: PushTokenSet? = Self.registeredToken
        // TODO: 이전에 업로드 성공한 토큰이 다시 등록되는 경우 무시, 계정 이관 이슈로 중복 토큰도 항상 업데이트
        // guard tokenSet != Self.registeredToken else {
        //     Log.info("Ignored already registered token set. (from: \(`func`))")
        //     return
        // }
        
        guard let fcmToken = tokenSet.fcm, let apns = tokenSet.apns else { return }
        Log.info("Firebase registration token: \(fcmToken) [with \(apns)] (from: \(function))")
        
        // 서버에 FCM token 등록
        if let fcmToken = tokenSet.fcm, let provider = self.provider {
            
            let request: AuthRequest = .updateFCM(fcmToken: fcmToken)
            provider.networkManager.request(Empty.self, request: request)
                .subscribe(
                    onNext: { _ in
                        Log.info("Update FCM token to server with", fcmToken)
                    },
                    onError: { _ in
                        Log.error("Failed to update FCM token to server: not found user")
                    }
                )
                .disposed(by: Self.fcmDisposeBag)
        } else {
            
            Self.registeredToken = prevTokenSet
            Log.info("Failed to update FCM token to server: not found device unique id")
        }
    }
    
    func registerFCMToken(from func: String) {
        let tokenSet = PushTokenSet(
            apns: nil,
            fcm: Messaging.messaging().fcmToken
        )
        self.registerFCMToken(with: tokenSet, `func`)
    }
}
