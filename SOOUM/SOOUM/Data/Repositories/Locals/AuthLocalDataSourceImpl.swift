//
//  AuthLocalDataSourceImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

class AuthLocalDataSourceImpl: AuthLocalDataSource {
    
    private let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func initializeAuthInfo() {
        
        self.provider.authManager.initializeAuthInfo()
    }
    
    func hasToken() -> Bool {
        
        let authInfo = self.provider.authManager.authInfo
        return authInfo.token.accessToken.isEmpty == false && authInfo.token.refreshToken.isEmpty == false
    }
    
    func tokens() -> Token {
        
        return self.provider.authManager.authInfo.token
    }
}
