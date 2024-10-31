//
//  AuthInfo.swift
//  SOOUM
//
//  Created by 오현식 on 10/27/24.
//

import Foundation


class AuthInfo {
    
    /// 기기 식별 아이디
    var deviceId: Data = .init()
    /// 토큰
    var token: Token = .init(accessToken: "", refreshToken: "")
}

extension AuthInfo {
    
    func initAuthInfo() {
        AuthKeyChain.shared.delete(.accessToken)
        AuthKeyChain.shared.delete(.refreshToken)
    }
    
    func updateToken(_ token: Token) {
        AuthKeyChain.shared.save(.accessToken, data: token.accessToken.data(using: .utf8))
        AuthKeyChain.shared.save(.refreshToken, data: token.refreshToken.data(using: .utf8))
    }
    
    static func loadInfo(_ authInfo: AuthInfo) -> AuthInfo {
        
        if let deviceId = AuthKeyChain.shared.load(.deviceId) {
            authInfo.deviceId = deviceId
        } else {
            let deviceId = UUID().uuidString
            let toData = deviceId.data(using: .utf8)!
            AuthKeyChain.shared.save(.deviceId, data: toData)
            authInfo.deviceId = toData
        }
        if let data = AuthKeyChain.shared.load(.accessToken),
           let accessToken = String(data: data, encoding: .utf8) {
            authInfo.token.accessToken = accessToken
        } else {
            authInfo.token.accessToken = ""
        }
        if let data = AuthKeyChain.shared.load(.refreshToken),
           let refreshToken = String(data: data, encoding: .utf8) {
            authInfo.token.refreshToken = refreshToken
        } else {
            authInfo.token.refreshToken = ""
        }
        print("""
            ℹ️ Call Info: \(authInfo)
                deviceId: \(String(data: authInfo.deviceId, encoding: .utf8)!)
                accessToken: \(authInfo.token.accessToken)
                refreshToken: \(authInfo.token.refreshToken)
        """)
        
        return authInfo
    }
}
