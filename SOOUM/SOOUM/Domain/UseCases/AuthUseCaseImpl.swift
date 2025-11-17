//
//  AuthUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

class AuthUseCaseImpl: AuthUseCase {
    
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func signUp(nickname: String, profileImageName: String?) -> Observable<Bool> {
        
        return self.repository.signUp(nickname: nickname, profileImageName: profileImageName)
    }
    
    func login() -> Observable<Bool> {
        
        return self.repository.login()
    }
    
    func withdraw(reaseon: String) -> Observable<Bool> {
        
        return self.repository.withdraw(reaseon: reaseon).map { $0 == 200 }
    }
    
    func initializeAuthInfo() {
        
        return self.repository.initializeAuthInfo()
    }
    
    func hasToken() -> Bool {
        
        return self.repository.hasToken()
    }
    
    func tokens() -> Token {
        
        return self.repository.tokens()
    }
    
    func encryptedDeviceId() -> Observable<String?> {
        
        return self.repository.encryptedDeviceId()
    }
}
