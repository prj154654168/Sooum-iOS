//
//  AuthRepositoryImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

class AuthRepositoryImpl: AuthRepository {
    
    private let remoteDataSource: AuthRemoteDataSource
    private let localDataSource: AuthLocalDataSource
    
    init(remoteDataSource: AuthRemoteDataSource, localDataSource: AuthLocalDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func signUp(nickname: String, profileImageName: String?) -> Observable<Bool> {
        
        self.remoteDataSource.signUp(nickname: nickname, profileImageName: profileImageName)
    }
    
    func login() -> Observable<Bool> {
        
        self.remoteDataSource.login()
    }
    
    func initializeAuthInfo() {
        
        self.localDataSource.initializeAuthInfo()
    }
    
    func hasToken() -> Bool {
        
        self.localDataSource.hasToken()
    }
    
    func tokens() -> Token {
        
        self.localDataSource.tokens()
    }
}
