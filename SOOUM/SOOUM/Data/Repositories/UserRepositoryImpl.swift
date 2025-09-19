//
//  UserRepositoryImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

class UserRepositoryImpl: UserRepository {
    
    private let remoteDataSource: UserRemoteDataSource
    
    init(remoteDataSource: UserRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func checkAvailable() -> Observable<CheckAvailableResponse> {
        
        return self.remoteDataSource.checkAvailable()
    }
    
    func nickname() -> Observable<NicknameResponse> {
        
        return self.remoteDataSource.nickname()
    }
    
    func validateNickname(nickname: String) -> Observable<NicknameValidateResponse> {
        
        return self.remoteDataSource.validateNickname(nickname: nickname)
    }
    
    func updateNickname(nickname: String) -> Observable<Int> {
        
        return self.remoteDataSource.updateNickname(nickname: nickname)
    }
    
    func presignedURL() -> Observable<ImageUrlInfoResponse> {
        
        return self.remoteDataSource.presignedURL()
    }
    
    func uploadImage(_ data: Data, with url: URL) -> Observable<Result<Void, Error>> {
        
        return self.remoteDataSource.uploadImage(data, with: url)
    }
    
    func updateImage(imageName: String) -> Observable<Int> {
        
        return self.remoteDataSource.updateImage(imageName: imageName)
    }
    
    func updateFCMToken(fcmToken: String) -> Observable<Int> {
        
        return self.remoteDataSource.updateFCMToken(fcmToken: fcmToken)
    }
}
