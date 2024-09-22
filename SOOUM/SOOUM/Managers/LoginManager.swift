//
//  LoginManager.swift
//  SOOUM
//
//  Created by JDeoks on 9/22/24.
//

import Foundation
import Security

class LoginManager {
    
    enum KeyChainKey: String {
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
        case deviceId = "deviceId"
    }
    
    static let shared = LoginManager()
    
    private init() { }
    
    /// 디바이스의 고유 UUID를 생성. 이미 존재할 경우 기존의 deviceId를 그대로 사용함.
    /// - Returns: 키체인에 UUID 저장이 성공하면 deviceId를 반환하고, 없으면 `nil`을 반환함.
    func initDeviceId() -> String? {
        if let currentDeviceID = getTokenFromKeychain(tokenType: .deviceId) {
            return currentDeviceID
        }
        let deviceId = UUID().uuidString
        guard let deviceIdData = deviceId.data(using: .utf8) else {
            return nil
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: KeyChainKey.deviceId.rawValue,
            kSecValueData as String: deviceIdData
        ]
                
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess ? deviceId : nil
    }
    
    /// 키체인에 토큰을 저장
    /// - Parameters:
    ///   - token: 저장할 토큰 값
    ///   - tokenType: 저장할 토큰의 타입 (accessToken, refreshToken 등)
    /// - Returns: 토큰 저장이 성공하면 `true`, 실패하면 `false`를 반환함.
    func saveTokenToKeychain(token: String, tokenType: KeyChainKey) -> Bool {
        let tokenData = token.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenType.rawValue,
            kSecValueData as String: tokenData
        ]
        
        // 이미 저장된 항목이 있으면 삭제 후 다시 저장
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    /// 키체인에서 토큰을 불러옴
    /// - Parameter tokenType: 불러올 토큰의 타입 (accessToken, refreshToken 등)
    /// - Returns: 토큰이 존재하면 해당 토큰 값을 반환하고, 없으면 `nil`을 반환함.
    func getTokenFromKeychain(tokenType: KeyChainKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenType.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let tokenData = item as? Data, let token = String(data: tokenData, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    /// 키체인에서 특정 토큰을 삭제
    /// - Parameter tokenType: 삭제할 토큰의 타입 (accessToken, refreshToken 등)
    /// - Returns: 토큰 삭제가 성공하면 `true`, 실패하면 `false`를 반환함.
    func deleteTokenFromKeychain(tokenType: KeyChainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenType.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
}
