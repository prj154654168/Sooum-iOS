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
    
    var deviceId: Data { get }
    var token: Token { get }
    var hasToken: Bool { get }
    func convertPEMToSecKey(pemString: String) -> SecKey?
    func encryptUUIDWithPublicKey(publicKey: SecKey) -> String?
    func reAuthenticate(_ accessToken: String, _ completion: @escaping(AuthResult) -> Void)
    func updateTokens(_ token: Token)
    func authPayloadByAccess() -> [String: String]
    func authPayloadByRefresh() -> [String: String]
}

class AuthManager: AuthManagerDelegate {
    
    static let shared = AuthManager()
    
    private var isReAuthenticating: Bool = false
    
    private var disposeBag = DisposeBag()
    
    var deviceId: Data {
        if let deviceId = AuthKeyChain.shared.load(.deviceId) {
            print("ℹ️ Call Info: DeviceId: \(String(data: deviceId, encoding: .utf8) ?? "")")
            return deviceId
        } else {
            let deviceId = UUID().uuidString
            let toData = deviceId.data(using: .utf8)!
            AuthKeyChain.shared.save(.deviceId, data: toData)
            print("ℹ️ Call Info: DeviceId: \(deviceId)")
            return toData
        }
    }
    
    var token: Token {
        var accessToken = ""
        if let data = AuthKeyChain.shared.load(.accessToken),
           let toString = String(data: data, encoding: .utf8) {
            accessToken = toString
        }
        var refreshToken = ""
        if let data = AuthKeyChain.shared.load(.refreshToken),
           let toString = String(data: data, encoding: .utf8) {
            refreshToken = toString
        }
        print("ℹ️ Call Info: Authenticate token\n AccessToken: \(accessToken)\n RefreshToken: \(refreshToken)")
        return Token(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    var hasToken: Bool {
        return self.token.accessToken.isEmpty == false && self.token.refreshToken.isEmpty == false
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
            self.deviceId as CFData,
            &error
        ) else {
            print("Error encrypting UUID: \(error?.takeRetainedValue().localizedDescription ?? "unknown error")")
            return nil
        }
        
        return (encryptedData as Data).base64EncodedString()
    }

    /*
        1. RefreshToken 이 KeyChain 에 존재하는지 확인
        2. 서버의 토큰이 만료된 상태(하지만 클라에서는 호출이 이루어지지 않아 만료 상태를 모르는 상태)에서 2개 이상의
        호출이 일어날 경우 동시에 재인증 과정이 진행될 수 있기 때문에, isReAuthenticating 플래그로 인증 중에 진입하는 경우 재시도하도록 한다.
        3. 재인증 완료된 후, 이전의 호출이 이전 토큰을 가지고 시도할 수 있기 때문에, 호출의 토큰과 현재 토큰이 같은 때만 통과시킨다
     */
    func reAuthenticate(_ accessToken: String, _ completion: @escaping (AuthResult) -> Void) {
        
        guard self.token.refreshToken.isEmpty == false else {
            let error = NSError(
                domain: "TARAS",
                code: -99,
                userInfo: [NSLocalizedDescriptionKey: "Refresh token not found"]
            )
            completion(.failure(error))
            return
        }
        
        guard self.isReAuthenticating == false, accessToken == self.token.accessToken else {
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
                            domain: "TARAS",
                            code: -99,
                            userInfo: [NSLocalizedDescriptionKey: "Session not refresh"]
                        )
                        completion(.failure(error))
                    } else {
                        
                        object.updateTokens(
                            .init(
                                accessToken: accessToken,
                                refreshToken: self.token.refreshToken
                            )
                        )
                        completion(.success)
                    }
                    
                    object.isReAuthenticating = false
                },
                onError: { object, error in
                    completion(.failure(error))
                
                    object.isReAuthenticating = false
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    func updateTokens(_ token: Token) {
        AuthKeyChain.shared.save(.accessToken, data: token.accessToken.data(using: .utf8))
        AuthKeyChain.shared.save(.refreshToken, data: token.refreshToken.data(using: .utf8))
    }
    
    func authPayloadByAccess() -> [String: String] {
        return ["Authorization": "Bearer \(self.token.accessToken)"]
    }
    
    func authPayloadByRefresh() -> [String: String] {
        return ["Authorization-refresh": "Bearer \(self.token.refreshToken)"]
    }
    
    func tempLog(type tokenType: String, _ string: String) {
        
        print("ℹ️ Call Info: \(tokenType) : \(string)")
    }
}
