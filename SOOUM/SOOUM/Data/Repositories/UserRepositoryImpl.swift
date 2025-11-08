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
    
    func postingPermission() -> Observable<PostingPermissionResponse> {
        
        return self.remoteDataSource.postingPermission()
    }
    
    func profile(userId: String?) -> Observable<ProfileInfoResponse> {
        
        return self.remoteDataSource.profile(userId: userId)
    }
    
    func updateMyProfile(nickname: String?, imageName: String?) -> Observable<Int> {
        
        return self.remoteDataSource.updateMyProfile(nickname: nickname, imageName: imageName)
    }
    
    func feedCards(userId: String, lastId: String?) -> Observable<ProfileCardInfoResponse> {
        
        return self.remoteDataSource.feedCards(userId: userId, lastId: lastId)
    }
    
    func myCommentCards(lastId: String?) -> Observable<ProfileCardInfoResponse> {
        
        return self.remoteDataSource.myCommentCards(lastId: lastId)
    }
    
    func followers(userId: String, lastId: String?) -> Observable<FollowInfoResponse> {
        
        return self.remoteDataSource.followers(userId: userId, lastId: lastId)
    }
    
    func followings(userId: String, lastId: String?) -> Observable<FollowInfoResponse> {
        
        return self.remoteDataSource.followings(userId: userId, lastId: lastId)
    }
    
    func updateFollowing(userId: String, isFollow: Bool) -> Observable<Int> {
        
        return self.remoteDataSource.updateFollowing(userId: userId, isFollow: isFollow)
    }
    
    func updateBlocked(id: String, isBlocked: Bool) -> Observable<Int> {
        
        return self.remoteDataSource.updateBlocked(id: id, isBlocked: isBlocked)
    }
}
