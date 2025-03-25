//
//  NetworkManager.swift
//  SOOUM
//
//  Created by 오현식 on 9/23/24.
//

import Foundation

import Alamofire
import FirebaseMessaging
import RxSwift


protocol NetworkManagerDelegate: AnyObject {
    
    func request<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<T>
    func upload(
        _ data: Data,
        to url: URLConvertible
    ) -> Observable<Result<Void, Error>>
    
    func registerFCMToken(with tokenSet: PushTokenSet, _ function: String)
    func registerFCMToken(from function: String)
}

class NetworkManager: CompositeManager<NetworkManagerConfiguration> {
    
    /// URLSession in Alamofire
    private let session: Session
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    override init(provider: ManagerTypeDelegate, configure: NetworkManagerConfiguration) {
        self.session = .init(
            configuration: configure.configuration.sessionConfiguration,
            interceptor: CompositeInterceptor(provider: provider),
            eventMonitors: [LogginMonitor()]
        )
        self.decoder = configure.configuration.decoder
        self.encoder = configure.configuration.encoder
        
        super.init(provider: provider, configure: configure)
    }
    
    private func setupError(_ message: String, with code: Int = -99) -> NSError {
        
        let error: NSError = .init(
            domain: "SOOUM",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
        return error
    }
}

extension NetworkManager: NetworkManagerDelegate {
    
    
    // MARK: Request network sevice
    
    func request<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<T> {
        return Observable.create { [weak self] observer -> Disposable in
            
            let task = self?.session.request(request)
                .validate(statusCode: 200..<500)
                .responseDecodable(
                    of: object,
                    decoder: self?.decoder ?? JSONDecoder(),
                    emptyResponseCodes: [200, 201, 204, 205]
                ) { response in
                    switch response.result {
                    case let .success(value):
                        if let error = response.error {
                            observer.onError(error)
                        } else {
                            observer.onNext(value)
                            observer.onCompleted()
                        }
                    case let .failure(error):
                        let statusCode = response.response?.statusCode
                        switch statusCode {
                        case 400:
                            let nsError = self?.setupError("Bad Request: HTTP 400 received.", with: 400) ?? .init()
                            observer.onError(nsError)
                            return
                        case 401:
                            let nsError = self?.setupError("Unauthorization: 401 received.", with: 401) ?? .init()
                            observer.onError(nsError)
                            return
                        case 403:
                            let nsError = self?.setupError("Expire RefreshToken: HTTP 403 received,", with: 403) ?? .init()
                            observer.onError(nsError)
                            return
                        case 418:
                            let nsError = self?.setupError("Stop using RefreshToken: HTTP 418 received,", with: 418) ?? .init()
                            observer.onError(nsError)
                            return
                        case 423:
                            let nsError = self?.setupError("LOCKED: HTTP 423 received.", with: 423) ?? .init()
                            observer.onError(nsError)
                            return
                        default:
                            break
                        }
                        
                        Log.error("Network or response format error: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
    
    func upload(
        _ data: Data,
        to url: URLConvertible
    ) -> Observable<Result<Void, Error>> {
        return Observable.create { [weak self] observer -> Disposable in
            
            let task = self?.session.upload(data, to: url, method: .put)
                .validate(statusCode: 200..<500)
                .response { response in
                    switch response.result {
                    case .success:
                        if let error = response.error {
                            observer.onError(error)
                        } else {
                            observer.onNext(.success(()))
                            observer.onCompleted()
                        }
                    case .failure(let error):
                        Log.error("Network or response format error: \(error)")
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
    
    
    // MARK: Register FCM token
    
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
