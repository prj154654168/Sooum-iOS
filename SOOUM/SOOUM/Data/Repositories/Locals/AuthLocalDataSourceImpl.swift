//
//  AuthLocalDataSourceImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

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
    
    func encryptedDeviceId() -> Observable<String?> {
        
        return self.provider.authManager.publicKey()
            .withUnretained(self)
            .flatMapLatest { object, publicKey -> Observable<String?> in
                if let publicKey = publicKey,
                   let secKey = object.provider.authManager.convertPEMToSecKey(pemString: publicKey) {
                    
                    let encryptedDeviceId = object.provider.authManager.encryptUUIDWithPublicKey(publicKey: secKey)
                    return .just(encryptedDeviceId)
                } else {
                    return .just(nil)
                }
            }
    }
}
