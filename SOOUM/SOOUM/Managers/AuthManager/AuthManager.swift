//
//  AuthManager.swift
//  SOOUM
//
//  Created by 오현식 on 10/26/24.
//

import Foundation
import Security

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
    func certification() -> Observable<Bool>
    func reAuthenticate(_ accessToken: String, _ completion: @escaping (AuthResult) -> Void)
    func initializeAuthInfo()
    func updateTokens(_ token: Token)
    func authPayloadByAccess() -> [String: String]
    func authPayloadByRefresh() -> [String: String]
}

class AuthManager: AuthManagerDelegate {
    
    static let shared = AuthManager()
    
    private var isReAuthenticating: Bool = false
    
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
    
    func convertPEMToSecKey(pemString: String) -> SecKey? {
        let keyString = pemString
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        guard let keyData = Data(base64Encoded: keyString) else {
            print("Failed to decode base64 string.")
            return nil
        }
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
        ]
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(keyData as CFData, attributes as CFDictionary, &error) else {
            print("Error creating SecKey: \(error?.takeRetainedValue().localizedDescription ?? "unknown error")")
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
            print("Error encrypting UUID: \(error?.takeRetainedValue().localizedDescription ?? "unknown error")")
            return nil
        }
        
        return (encryptedData as Data).base64EncodedString()
    }
    
    // TODO: 회원가입 시 매개변수 추가
    func join() -> Observable<Bool> {
        
        let networkManager = NetworkManager.shared
        return networkManager.request(RSAKeyResponse.self, request: AuthRequest.getPublicKey)
            .map(\.publicKey)
            .withUnretained(self)
            .flatMapLatest { object, publicKey -> Observable<Bool> in
                
                if let secKey = object.convertPEMToSecKey(pemString: publicKey),
                   let encryptedDeviceId = object.encryptUUIDWithPublicKey(publicKey: secKey) {
                    
                    let request: AuthRequest = .signUp(
                        encryptedDeviceId: encryptedDeviceId,
                        // TODO: 추후 fcm 등록 후 추가
                        firebaseToken: "example_firebase_token",
                        isAllowNotify: true,
                        isAllowTermOne: true,
                        isAllowTermTwo: true,
                        isAllowTermThree: true
                    )
                    return networkManager.request(SignUpResponse.self, request: request)
                        .map { response in
                            object.authInfo.updateToken(response.token)
                            return true
                        }
                }
                return .just(false)
            }
    }
    
    func certification() -> Observable<Bool> {
        
        let networkManager = NetworkManager.shared
        return networkManager.request(RSAKeyResponse.self, request: AuthRequest.getPublicKey)
            .map(\.publicKey)
            .withUnretained(self)
            .flatMapLatest { object, publicKey -> Observable<Bool> in
                
                if let secKey = object.convertPEMToSecKey(pemString: publicKey),
                   let encryptedDeviceId = object.encryptUUIDWithPublicKey(publicKey: secKey) {
                    
                    let request: AuthRequest = .login(encryptedDeviceId: encryptedDeviceId)
                    return networkManager.request(SignInResponse.self, request: request)
                        .map { response -> Bool in
                            if response.isRegistered, let token = response.token {
                                object.authInfo.updateToken(token)
                                return true
                            }
                            return false
                        }
                }
                return .just(false)
            }
    }

    /*
        1. RefreshToken 이 KeyChain 에 존재하는지 확인
        2. 서버의 토큰이 만료된 상태(하지만 클라에서는 호출이 이루어지지 않아 만료 상태를 모르는 상태)에서 2개 이상의
        호출이 일어날 경우 동시에 재인증 과정이 진행될 수 있기 때문에, isReAuthenticating 플래그로 인증 중에 진입하는 경우 재시도하도록 한다.
        3. 재인증 완료된 후, 이전의 호출이 이전 토큰을 가지고 시도할 수 있기 때문에, 호출의 토큰과 현재 토큰이 같은 때만 통과시킨다
        4. RefreshToken 도 유효하지 않다면 로그인 시도
     */
    func reAuthenticate(_ accessToken: String, _ completion: @escaping (AuthResult) -> Void) {
        
        let token = self.authInfo.token
        
        guard authInfo.token.refreshToken.isEmpty == false else {
            let error = NSError(
                domain: "SOOUM",
                code: -99,
                userInfo: [NSLocalizedDescriptionKey: "Refresh token not found"]
            )
            completion(.failure(error))
            return
        }
        
        guard self.isReAuthenticating == false, accessToken == token.accessToken else {
            completion(.success)
            return
        }
        
        self.isReAuthenticating = true
        
        let networkManager = NetworkManager.shared
        let request: AuthRequest = .reAuthenticationWithRefreshSession
        networkManager.request(ReAuthenticationResponse.self, request: request)
            .map(\.accessToken)
            .subscribe(
                with: self,
                onNext: { object, accessToken in
                    if accessToken.isEmpty {
                        let error = NSError(
                            domain: "SOOUM",
                            code: -99,
                            userInfo: [NSLocalizedDescriptionKey: "Session not refresh"]
                        )
                        completion(.failure(error))
                    } else {
                        
                        object.updateTokens(
                            .init(
                                accessToken: accessToken,
                                refreshToken: token.refreshToken
                            )
                        )
                        completion(.success)
                    }
                    
                    object.isReAuthenticating = false
                },
                onError: { object, error in
                    
                    object.certification()
                        .subscribe(onNext: { isRegistered in
                            if isRegistered {
                                completion(.success)
                            } else {
                                completion(.failure(error))
                            }
                        })
                        .disposed(by: self.disposeBag)
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
