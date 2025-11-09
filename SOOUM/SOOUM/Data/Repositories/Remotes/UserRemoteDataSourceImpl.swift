//
//  UserRemoteDataSourceImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

class UserRemoteDataSourceImpl: UserRemoteDataSource {
    
    private let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func checkAvailable() -> Observable<CheckAvailableResponse> {
        
        return self.provider.authManager.available()
    }
    
    func nickname() -> Observable<NicknameResponse> {
        
        let request: UserRequest = .nickname
        return self.provider.networkManager.fetch(NicknameResponse.self, request: request)
    }
    
    func validateNickname(nickname: String) -> Observable<NicknameValidateResponse> {
        
        let request: UserRequest = .validateNickname(nickname: nickname)
        return self.provider.networkManager.perform(NicknameValidateResponse.self, request: request)
    }
    
    func updateNickname(nickname: String) -> Observable<Int> {
        
        let request: UserRequest = .updateNickname(nickname: nickname)
        return self.provider.networkManager.perform(request)
    }
    
    func presignedURL() -> Observable<ImageUrlInfoResponse> {
        
        let request: UserRequest = .presignedURL
        return self.provider.networkManager.fetch(ImageUrlInfoResponse.self, request: request)
    }
    
    func uploadImage(_ data: Data, with url: URL) -> Observable<Result<Void, Error>> {
        
        return self.provider.networkManager.upload(data, to: url)
    }
    
    func updateImage(imageName: String) -> Observable<Int> {
        
        let request: UserRequest = .updateImage(imageName: imageName)
        return self.provider.networkManager.perform(request)
    }
    
    func updateFCMToken(fcmToken: String) -> Observable<Int> {
        
        let request: UserRequest = .updateFCMToken(fcmToken: fcmToken)
        return self.provider.networkManager.perform(request)
    }
    
    func postingPermission() -> Observable<PostingPermissionResponse> {
        
        let request: UserRequest = .postingPermission
        return self.provider.networkManager.fetch(PostingPermissionResponse.self, request: request)
    }
    
    func profile(userId: String?) -> Observable<ProfileInfoResponse> {
        
        let request: UserRequest = .profile(userId: userId)
        return self.provider.networkManager.fetch(ProfileInfoResponse.self, request: request)
    }
    
    func updateMyProfile(nickname: String?, imageName: String?) -> Observable<Int> {
        
        let request: UserRequest = .updateMyProfile(nickname: nickname, imageName: imageName)
        return self.provider.networkManager.perform(request)
    }
    
    func feedCards(userId: String, lastId: String?) -> Observable<ProfileCardInfoResponse> {
        
        let request: UserRequest = .feedCards(userId: userId, lastId: lastId)
        return self.provider.networkManager.fetch(ProfileCardInfoResponse.self, request: request)
    }
    
    func myCommentCards(lastId: String?) -> Observable<ProfileCardInfoResponse> {
        
        let request: UserRequest = .myCommentCards(lastId: lastId)
        return self.provider.networkManager.fetch(ProfileCardInfoResponse.self, request: request)
    }
    
    func followers(userId: String, lastId: String?) -> Observable<FollowInfoResponse> {
        
        let request: UserRequest = .followers(userId: userId, lastId: lastId)
        return self.provider.networkManager.fetch(FollowInfoResponse.self, request: request)
    }
    
    func followings(userId: String, lastId: String?) -> Observable<FollowInfoResponse> {
        
        let request: UserRequest = .followings(userId: userId, lastId: lastId)
        return self.provider.networkManager.fetch(FollowInfoResponse.self, request: request)
    }
    
    func updateFollowing(userId: String, isFollow: Bool) -> Observable<Int> {
        
        let request: UserRequest = .updateFollowing(userId: userId, isFollow: isFollow)
        return self.provider.networkManager.perform(request)
    }
    
    func updateBlocked(id: String, isBlocked: Bool) -> Observable<Int> {
        
        let request: UserRequest = .updateBlocked(id: id, isBlocked: isBlocked)
        return self.provider.networkManager.perform(request)
    }
    
    func updateNotify(isAllowNotify: Bool) -> Observable<Int> {
        
        let request: UserRequest = .updateNotify(isAllowNotify: isAllowNotify)
        return self.provider.networkManager.perform(request)
    }
}
