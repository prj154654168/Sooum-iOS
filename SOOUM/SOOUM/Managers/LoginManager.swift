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
        case accessToken
        case refreshToken
        case deviceId
    }
    
    static let shared = LoginManager()
    
    private let service: String
    
    private init() {
        // Info.plist에서 "service" 키로 값을 읽어옴
        if let serviceName = Bundle.main.object(forInfoDictionaryKey: "service") as? String {
            self.service = serviceName
            print("serviceName:", serviceName)
        } else {
            self.service = "com.sooum.dev" 
        }
    }
    
    /// 디바이스의 고유 UUID를 생성. 이미 존재할 경우 기존의 deviceId를 그대로 사용함.
    /// - Returns: 키체인에 UUID 저장이 성공하면 deviceId를 반환하고, 없으면 `nil`을 반환함.
    func initDeviceId() -> String? {
        if let currentDeviceID = getTokenFromKeychain(tokenType: .deviceId) {
            print("\(type(of: self)) - \(#function)", "성공: 기존 deviceId 존재")
            return currentDeviceID
        }
        let deviceId = UUID().uuidString
        guard let deviceIdData = deviceId.data(using: .utf8) else {
            print("\(type(of: self)) - \(#function)", "실패: deviceId 저장 실패")
            return nil
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: KeyChainKey.deviceId.rawValue,
            kSecAttrService as String: self.service,
            kSecValueData as String: deviceIdData
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil) == errSecSuccess
        
        print("\(type(of: self)) - \(#function)", "성공: UUID 저장 완료")

        return status ? deviceId : nil
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
            kSecAttrService as String: self.service,
            kSecValueData as String: tokenData
        ]
        
        // 이미 저장된 항목이 있으면 삭제 후 다시 저장
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil) == errSecSuccess
        
        print("\(type(of: self)) - \(#function)", status ? "성공" : "실패")
        
        return status
    }
    
    /// 키체인에서 토큰을 불러옴
    /// - Parameter tokenType: 불러올 토큰의 타입 (accessToken, refreshToken 등)
    /// - Returns: 토큰이 존재하면 해당 토큰 값을 반환하고, 없으면 `nil`을 반환함.
    func getTokenFromKeychain(tokenType: KeyChainKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenType.rawValue,
            kSecAttrService as String: self.service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess
        
        guard status,
              let tokenData = item as? Data,
              let token = String(data: tokenData, encoding: .utf8) else {
            print("\(type(of: self)) - \(#function)", "실패: 데이터 불러오기 실패")
            return nil
        }
        print("\(type(of: self)) - \(#function)", "성공")
        return token
    }

    
    /// 키체인에서 특정 토큰을 삭제
    /// - Parameter tokenType: 삭제할 토큰의 타입 (accessToken, refreshToken 등)
    /// - Returns: 토큰 삭제가 성공하면 `true`, 실패하면 `false`를 반환함.
    func deleteTokenFromKeychain(tokenType: KeyChainKey) -> Bool {
        print("\(type(of: self)) - \(#function)")

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenType.rawValue,
            kSecAttrService as String: self.service
        ]
        
        let status = SecItemDelete(query as CFDictionary) == errSecSuccess
        print("\(type(of: self)) - \(#function)", status ? "성공" : "실패")
        return status
    }
}
