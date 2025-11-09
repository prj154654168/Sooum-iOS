//
//  AuthManager.swift
//  SOOUM
//
//  Created by 오현식 on 10/26/24.
//

import Foundation
import Security

import Alamofire

import RxSwift


enum AuthResult {
    case success
    case failure(Error)
}

protocol AuthManagerDelegate: AnyObject {
    
    var authInfo: AuthInfo { get }
    var hasToken: Bool { get }
    func convertPEMToSecKey(pemString: String) -> SecKey?
    func encryptUUIDWithPublicKey(publicKey: SecKey) -> String?
    func publicKey() -> Observable<String?>
    func available() -> Observable<CheckAvailableResponse>
    func join(nickname: String, profileImageName: String?) -> Observable<Bool>
    func certification() -> Observable<Bool>
    func reAuthenticate(_ token: Token, _ completion: @escaping (AuthResult) -> Void)
    func initializeAuthInfo()
    func updateTokens(_ token: Token)
    func authPayloadByAccess() -> [String: String]
    func authPayloadByRefresh() -> [String: String]
}

class AuthManager: CompositeManager<AuthManagerConfiguration> {
    
    private var isReAuthenticating: Bool = false
    private var pendingResults: [(AuthResult) -> Void] = []
    
    private var disposeBag = DisposeBag()
    
    var authInfo: AuthInfo {
        var authInfo = AuthInfo()
        authInfo = AuthInfo.loadInfo(authInfo)
        return authInfo
    }
    
    var hasToken: Bool {
        let token = self.authInfo.token
        return !token.accessToken.isEmpty && !token.refreshToken.isEmpty
    }
    
    override init(provider: ManagerTypeDelegate, configure: AuthManagerConfiguration) {
        super.init(provider: provider, configure: configure)
    }
}

extension AuthManager: AuthManagerDelegate {
    
    
    // MARK: Asymmetric encryption
    
    func convertPEMToSecKey(pemString: String) -> SecKey? {
        let keyString = pemString
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        guard let keyData = Data(base64Encoded: keyString) else {
            Log.fail("Failed to decode base64 string.")
            return nil
        }
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
        ]
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error) else {
            Log.error("Error creating SecKey: \(error?.takeRetainedValue().localizedDescription ?? "unknown error")")
            return nil
        }
        
        return secKey
    }
    
    func encryptUUIDWithPublicKey(publicKey: SecKey) -> String? {
        
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(
            publicKey,
            .rsaEncryptionPKCS1,
            self.authInfo.deviceId as CFData,
            &error
        ) else {
            Log.error("Error encrypting UUID: \(error?.takeRetainedValue().localizedDescription ?? "unknown error")")
            return nil
        }
        
        return (encryptedData as Data).base64EncodedString()
    }
    
    
    // MARK: Account Verification
    
    func publicKey() -> Observable<String?> {
        
        guard let provider = self.provider else { return .just(nil) }
        
        let request: AuthRequest = .publicKey
        return provider.networkManager.fetch(KeyInfoResponse.self, request: request)
            .map(\.publicKey)
    }
    
    func available() -> Observable<CheckAvailableResponse> {
        
        return self.publicKey()
            .withUnretained(self)
            .flatMapLatest { object, publicKey -> Observable<CheckAvailableResponse> in
                
                if let publicKey = publicKey,
                   let secKey = object.convertPEMToSecKey(pemString: publicKey),
                   let encryptedDeviceId = object.encryptUUIDWithPublicKey(publicKey: secKey),
                   let provider = object.provider {
                    
                    let request: UserRequest = .checkAvailable(encryptedDeviceId: encryptedDeviceId)
                    return provider.networkManager.perform(CheckAvailableResponse.self, request: request)
                } else {
                    return .just(CheckAvailableResponse.emptyValue())
                }
            }
    }
    
    func join(nickname: String, profileImageName: String?) -> Observable<Bool> {
        
        return self.publicKey()
            .withUnretained(self)
            .flatMapLatest { object, publicKey -> Observable<Bool> in
                
                if let publicKey = publicKey,
                   let secKey = object.convertPEMToSecKey(pemString: publicKey),
                   let encryptedDeviceId = object.encryptUUIDWithPublicKey(publicKey: secKey),
                   let provider = object.provider {
                    
                    let request: AuthRequest = .signUp(
                        encryptedDeviceId: encryptedDeviceId,
                        isNotificationAgreed: provider.pushManager.notificationStatus,
                        nickname: nickname,
                        profileImageName: profileImageName
                    )
                    return provider.networkManager.perform(SignUpResponse.self, request: request)
                        .map(\.token)
                        .flatMapLatest { token -> Observable<Bool> in
                            
                            // session token 업데이트
                            object.authInfo.updateToken(token)
                            
                            // FCM token 업데이트
                            provider.networkManager.registerFCMToken(from: #function)
                            return .just(true)
                        }
                        .catchAndReturn(false)
                } else {
                    return .just(false)
                }
            }
    }
    
    func certification() -> Observable<Bool> {
        
        return self.publicKey()
            .withUnretained(self)
            .flatMapLatest { object, publicKey -> Observable<Bool> in
            
                if let publicKey = publicKey,
                   let secKey = object.convertPEMToSecKey(pemString: publicKey),
                   let encryptedDeviceId = object.encryptUUIDWithPublicKey(publicKey: secKey),
                   let provider = object.provider {
                    
                    let request: AuthRequest = .login(encryptedDeviceId: encryptedDeviceId)
                    return provider.networkManager.perform(LoginResponse.self, request: request)
                        .map(\.token)
                        .flatMapLatest { token -> Observable<Bool> in
                            
                            // session token 업데이트
                            object.authInfo.updateToken(token)
                            
                            // FCM token 업데이트
                            provider.networkManager.registerFCMToken(from: #function)
                            return .just(true)
                        }
                        .catchAndReturn(false)
                } else {
                    return .just(false)
                }
            }
    }

    /*
        1. RefreshToken 이 KeyChain 에 존재하는지 확인
        2. 서버의 토큰이 만료된 상태(하지만 클라에서는 호출이 이루어지지 않아 만료 상태를 모르는 상태)에서 2개 이상의
        호출이 일어날 경우 동시에 재인증 과정이 진행될 수 있기 때문에, isReAuthenticating 플래그로 인증 중에 진입하는 경우 재시도하도록 한다.
        3. 재인증 완료된 후, 이전의 호출이 이전 토큰을 가지고 시도할 수 있기 때문에, 호출의 토큰과 현재 토큰이 같은 때만 통과시킨다
        4. RefreshToken 도 유효하지 않다면 로그인 시도
     */
    func reAuthenticate(_ token: Token, _ completion: @escaping (AuthResult) -> Void) {
        
        guard self.authInfo.token.refreshToken.isEmpty == false else {
            let error = NSError(
                domain: "SOOUM",
                code: -99,
                userInfo: [NSLocalizedDescriptionKey: "Refresh token not found"]
            )
            completion(.failure(error))
            return
        }
        
        /// 1개 이상의 API에서 reAuthenticate 요청 했을 때,
        /// 기존 요청이 끝날 떄까지 대기
        guard self.isReAuthenticating == false else {
            self.pendingResults.append(completion)
            return
        }
        
        /// AccessToken이 업데이트 됐다면, 즉시 성공 처리
        guard token == self.authInfo.token else {
            completion(.success)
            return
        }
        
        self.isReAuthenticating = true
        self.pendingResults.append(completion)
        
        guard let provider = self.provider else { return }
        
        let request: AuthRequest = .reAuthenticationWithRefreshSession(token: token)
        provider.networkManager.perform(TokenResponse.self, request: request)
            .map(\.token)
            .subscribe(
                with: self,
                onNext: { object, token in
                
                    if token.accessToken.isEmpty || token.refreshToken.isEmpty {
                        let error = NSError(
                            domain: "SOOUM",
                            code: -99,
                            userInfo: [NSLocalizedDescriptionKey: "Session not refresh"]
                        )
                        
                        object.excutePendingResults(.failure(error))
                    } else {
                        
                        object.updateTokens(token)
                        
                        // FCM token 업데이트
                        provider.networkManager.registerFCMToken(from: #function)
                        
                        object.excutePendingResults(.success)
                    }
                    
                    object.isReAuthenticating = false
                },
                onError: { object, error in
                    
                    // TODO: 임시, 리프레쉬 토큰 만료 에러코드가 정의되지 않음
                    // let errorCode = (error as NSError).code
                    // if case 403 = errorCode {
                    //
                    //     object.certification()
                    //         .subscribe(onNext: { isRegistered in
                    //             object.excutePendingResults(isRegistered ? .success : .failure(error))
                    //         })
                    //         .disposed(by: object.disposeBag)
                    // }
                    object.certification()
                        .subscribe(onNext: { isRegistered in
                            object.excutePendingResults(isRegistered ? .success : .failure(error))
                        })
                        .disposed(by: object.disposeBag)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    func initializeAuthInfo() {
        self.authInfo.initAuthInfo()
    }
    
    func updateTokens(_ token: Token) {
        self.authInfo.updateToken(token)
    }
    
    func authPayloadByAccess() -> [String: String] {
        return ["Authorization": "Bearer \(self.authInfo.token.accessToken)"]
    }
    
    func authPayloadByRefresh() -> [String: String] {
        return ["Authorization": "Bearer \(self.authInfo.token.refreshToken)"]
    }
}

extension AuthManager {
    
    /// success 또는 failure가 발생하면 모든 API 요청에 새로운 토큰을 적용하도록 실행
    private func excutePendingResults(_ result: AuthResult) {
        self.pendingResults.forEach { $0(result) }
        self.pendingResults.removeAll()
    }
}
