//
//  UserUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

class UserUseCaseImpl: UserUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func isAvailableCheck() -> Observable<CheckAvailable> {
        
        return self.repository.checkAvailable().map { $0.checkAvailable }
    }
    
    func nickname() -> Observable<String> {
        
        return self.repository.nickname().map { $0.nickname }
    }
    
    func isNicknameValid(nickname: String) -> Observable<Bool> {
        
        return self.repository.validateNickname(nickname: nickname).map { $0.isAvailable }
    }
    
    func updateNickname(nickname: String) -> Observable<Bool> {
        
        return self.repository.updateNickname(nickname: nickname).map { $0 == 200 }
    }
    
    func presignedURL() -> Observable<ImageUrlInfo> {
        
        return self.repository.presignedURL().map { $0.imageUrlInfo }
    }
    
    func uploadImage(_ data: Data, with url: URL) -> Observable<Bool> {
        
        return self.repository.uploadImage(data, with: url)
            .map { _ in true }
            .catchAndReturn(false)
    }
    
    func updateImage(imageName: String) -> Observable<Bool> {
        
        return self.repository.updateImage(imageName: imageName).map { $0 == 200 }
    }
    
    func updateFCMToken(fcmToken: String) -> Observable<Bool> {
        
        return self.repository.updateFCMToken(fcmToken: fcmToken).map { $0 == 200 }
    }
}
