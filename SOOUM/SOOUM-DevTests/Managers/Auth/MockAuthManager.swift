//
//  MockAuthManager.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/1/25.
//

@testable import SOOUM_Dev

import Foundation
import Security

import RxSwift


class MockAuthManager: CompositeManager<AuthManagerConfiguration>, AuthManagerDelegate {
    
    private let deviceId: String = "mock-device-id"
    private let accessToken: String = "mock-access-token"
    private let refreshToken: String = "mock-refresh-token"
    
    private lazy var _authInfo: AuthInfo = AuthInfo()
    
    let publicKey = """
    -----BEGIN PUBLIC KEY-----
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7qG+zMd5Zb5Y9LVFnM7g
    R7eDyzm1Kb5DgBvQMuI1VXa+3B7YVc+J3LK3RHrDZLC2ZT/X4V3SNE4X8cPZUBDh
    9I+4lq5tX5N8kWqrx81PswHe1X9ZY7Qw9v2ZMJGmWd9pyJlHKQoUHRcixJmP7s5v
    9W1B+TuJ1S8hYBmRo7jA4b/Jf3m6kdWblF+P9VRno+UslQYF1cYgKJ7X/7nAeI5F
    fy7/DQj+SEBZ5U4HMPPbJRMlOHXcMHRXjXK6Gd1e+lVV9iLjRrMff2M+ZCfOm1ZT
    EiwM+6yV4IzXkYY4gT47av/hXa2UUVNn/NrWxW+J/Jzq5Fbzf+Wg2H75YX5y+swO
    VwIDAQAB
    -----END PUBLIC KEY-----
    """

    var shouldJoinSuccess: Bool = true
    var shouldCertificationSuccess: Bool = true
    
    var isReAuthenticating: Bool = false
    
    var disposeBag = DisposeBag()
    
    var authInfo: AuthInfo {
        return self._authInfo
    }
    
    var hasToken: Bool {
        let token = self.authInfo.token
        return token.accessToken.isEmpty == false && token.refreshToken.isEmpty == false
    }
    
    override init(provider: ManagerTypeDelegate, configure: AuthManagerConfiguration) {
        super.init(provider: provider, configure: configure)
        
        self.authInfo.token.accessToken = self.accessToken
        self.authInfo.token.refreshToken = self.refreshToken
    }
    
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
        return self.deviceId.isEmpty ? nil : "encrypted-\(self.deviceId)"
    }
    
    func join() -> Observable<Bool> {
        // 성공 시나리오 시뮬레이션
        if self.shouldJoinSuccess {
            return Observable.just(self.publicKey)
                .withUnretained(self)
                .map { object, publicKey in
                    // 1. PEM to SecKey 변환 시뮬레이션
                    let secKey = object.convertPEMToSecKey(pemString: publicKey)
                    // 2. UUID 암호화 시뮬레이션
                    if let secKey = secKey,
                       object.encryptUUIDWithPublicKey(publicKey: secKey) != nil {
                        // 3. 성공적인 회원가입 시뮬레이션
                        return true
                    } else {
                        return false
                    }
                }
        } else {
            // 실패 시나리오 시뮬레이션
            return Observable.just(false)
        }
    }
    
    func certification() -> Observable<Bool> {
        // 성공 시나리오 시뮬레이션
        if self.shouldCertificationSuccess {
            return Observable.just(self.publicKey)
                .withUnretained(self)
                .map { object, publicKey in
                    // 1. PEM to SecKey 변환 시뮬레이션
                    let secKey = object.convertPEMToSecKey(pemString: publicKey)
                    // 2. UUID 암호화 시뮬레이션
                    if let secKey = secKey,
                       object.encryptUUIDWithPublicKey(publicKey: secKey) != nil {
                        // 3. 성공적인 회원가입 시뮬레이션
                        return true
                    } else {
                        return false
                    }
                }
        } else {
            // 실패 시나리오 시뮬레이션
            return Observable.just(false)
        }
    }
    
    func reAuthenticate(_ accessToken: String, _ completion: @escaping (AuthResult) -> Void) {
        guard self.isReAuthenticating == false, accessToken == self.authInfo.token.accessToken else {
            completion(.failure(NSError(domain: "SOOUM", code: 0)))
            return
        }

        self.isReAuthenticating = true

        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
            completion(.success)
            self.isReAuthenticating = false
        }
    }
    
    func initializeAuthInfo() {
        self.authInfo.token.accessToken = ""
        self.authInfo.token.refreshToken = ""
    }
    
    func updateTokens(_ token: Token) {
        self.authInfo.token = token
    }
    
    func authPayloadByAccess() -> [String: String] {
        return ["Authorization": "Bearer \(self.authInfo.token.accessToken)"]
    }
    
    func authPayloadByRefresh() -> [String: String] {
        return ["Authorization": "Bearer \(self.authInfo.token.refreshToken)"]
    }
}
