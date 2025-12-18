//
//  AuthRemoteDataSourceImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

class AuthRemoteDataSourceImpl: AuthRemoteDataSource {
    
    private let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func signUp(nickname: String, profileImageName: String?) -> Observable<Bool> {
        
        return self.provider.authManager.join(nickname: nickname, profileImageName: profileImageName)
    }
    
    func login() -> Observable<Bool> {
        
        return self.provider.authManager.certification()
    }
    
    func withdraw(reaseon: String) -> Observable<Int> {
        
        let token = self.provider.authManager.authInfo.token
        let request: AuthRequest = .withdraw(token: token, reason: reaseon)
        return self.provider.networkManager.perform(request)
    }
}
