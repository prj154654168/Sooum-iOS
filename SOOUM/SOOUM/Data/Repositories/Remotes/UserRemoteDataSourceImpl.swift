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
        return self.provider.networkManager.perform(Int.self, request: request)
    }
    
    func presignedURL() -> Observable<ImageUrlInfoResponse> {
        
        let request: UserRequest = .presignedURL
        return self.provider.networkManager.perform(ImageUrlInfoResponse.self, request: request)
    }
    
    func uploadImage(_ data: Data, with url: URL) -> Observable<Result<Void, Error>> {
        
        return self.provider.networkManager.upload(data, to: url)
    }
    
    func updateImage(imageName: String) -> Observable<Int> {
        
        let request: UserRequest = .updateImage(imageName: imageName)
        return self.provider.networkManager.perform(Int.self, request: request)
    }
    
    func updateFCMToken(fcmToken: String) -> Observable<Int> {
        
        let request: UserRequest = .updateFCMToken(fcmToken: fcmToken)
        return self.provider.networkManager.perform(Int.self, request: request)
    }
    
    func postingPermission() -> Observable<PostingPermissionResponse> {
        
        let request: UserRequest = .postingPermission
        return self.provider.networkManager.fetch(PostingPermissionResponse.self, request: request)
    }
}
