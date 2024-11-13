//
//  AuthKeyChain.swift
//  SOOUM
//
//  Created by 오현식 on 10/26/24.
//

import Foundation
import Security


class AuthKeyChain {
    
    enum TokenType: String {
        case accessToken
        case refreshToken
        /// deviceId은 앱 첫 실행 시 keyChain에 저장 후 절대 삭제 X
        case deviceId
    }
    
    static let shared = AuthKeyChain()
    
    private let service: String = "com.sooum.token"
    
    /// 키체인에 토큰을 저장
    /// - Parameters:
    ///   - tokenType: 저장할 토큰의 타입 (accessToken, refreshToken, deviceId)
    ///   - data: 저장할 토큰 값
    /// - Returns: 토큰 저장이 성공하면 `true`, 실패하면 `false`를 반환함.
    func save(_ tokenType: TokenType, data: Data?) {
        guard let data = data else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenType.rawValue,
            kSecAttrService as String: self.service,
            kSecValueData as String: data
        ]
        
        // 이미 저장된 항목이 있으면 삭제 후 다시 저장
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    /// 키체인에서 토큰을 불러옴
    /// - Parameter tokenType: 불러올 토큰의 타입 (accessToken, refreshToken, deviceId)
    /// - Returns: 토큰이 존재하면 해당 토큰 값을 반환하고, 없으면 `nil`을 반환함.
    func load(_ tokenType: TokenType) -> Data? {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenType.rawValue,
            kSecAttrService as String: self.service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess
        
        if status, let data = result as? Data { return data }
        return nil
    }
    
    /// 키체인에서 특정 토큰을 삭제
    /// - Parameter tokenType: 삭제할 토큰의 타입 (accessToken, refreshToken 등)
    /// - Returns: 토큰 삭제가 성공하면 `true`, 실패하면 `false`를 반환함.
    func delete(_ tokenType: TokenType) {
        // TODO: - 주석 풀기
        //        guard tokenType != .deviceId else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenType.rawValue,
            kSecAttrService as String: self.service
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
