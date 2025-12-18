//
//  SettingsRemoteDataSourceImpl.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Foundation

import RxSwift

class SettingsRemoteDataSourceImpl: SettingsRemoteDataSource {
    
    private let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func rejoinableDate() -> Observable<RejoinableDateInfoResponse> {
        
        let request: SettingsRequest = .rejoinableDate
        return self.provider.networkManager.fetch(RejoinableDateInfoResponse.self, request: request)
    }
    
    func issue() -> Observable<TransferCodeInfoResponse> {
        
        let request: SettingsRequest = .transferIssue
        return self.provider.networkManager.fetch(TransferCodeInfoResponse.self, request: request)
    }
    
    func enter(code: String, encryptedDeviceId: String) -> Observable<Int> {
        
        let request: SettingsRequest = .transferEnter(code: code, encryptedDeviceId: encryptedDeviceId)
        return self.provider.networkManager.perform(request)
    }
    
    func update() -> Observable<TransferCodeInfoResponse> {
        
        let request: SettingsRequest = .transferUpdate
        return self.provider.networkManager.perform(TransferCodeInfoResponse.self, request: request)
    }
    
    func blockUsers(lastId: String?) -> Observable<BlockUsersInfoResponse> {
        
        let request: SettingsRequest = .blockUsers(lastId: lastId)
        return self.provider.networkManager.fetch(BlockUsersInfoResponse.self, request: request)
    }
    
    func updateNotify(isAllowNotify: Bool) -> Observable<Int> {
        
        let request: UserRequest = .updateNotify(isAllowNotify: isAllowNotify)
        return self.provider.networkManager.perform(request)
    }
}
