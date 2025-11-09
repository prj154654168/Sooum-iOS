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
    
    func postingPermission() -> Observable<PostingPermission> {
        
        return self.repository.postingPermission().map { $0.postingPermission }
    }
    
    func profile(userId: String?) -> Observable<ProfileInfo> {
        
        return self.repository.profile(userId: userId).map { $0.profileInfo }
    }
    
    func updateMyProfile(nickname: String?, imageName: String?) -> Observable<Bool> {
        
        return self.repository.updateMyProfile(nickname: nickname, imageName: imageName).map { $0 == 200 }
    }
    
    func feedCards(userId: String, lastId: String?) -> Observable<[ProfileCardInfo]> {
        
        return self.repository.feedCards(userId: userId, lastId: lastId).map { $0.cardInfos }
    }
    
    func myCommentCards(lastId: String?) -> Observable<[ProfileCardInfo]> {
        
        return self.repository.myCommentCards(lastId: lastId).map { $0.cardInfos }
    }
    
    func followers(userId: String, lastId: String?) -> Observable<[FollowInfo]> {
        
        return self.repository.followers(userId: userId, lastId: lastId).map { $0.followInfos }
    }
    
    func followings(userId: String, lastId: String?) -> Observable<[FollowInfo]> {
        
        return self.repository.followings(userId: userId, lastId: lastId).map { $0.followInfos }
    }
    
    func updateFollowing(userId: String, isFollow: Bool) -> Observable<Bool> {
        
        return self.repository.updateFollowing(userId: userId, isFollow: isFollow).map { $0 == 200 }
    }
    
    func updateBlocked(id: String, isBlocked: Bool) -> Observable<Bool> {
        
        return self.repository.updateBlocked(id: id, isBlocked: isBlocked).map { $0 == 200 }
    }
    
    func updateNotify(isAllowNotify: Bool) -> Observable<Bool> {
        
        return self.repository.updateNotify(isAllowNotify: isAllowNotify).map { $0 == 200 }
    }
}
