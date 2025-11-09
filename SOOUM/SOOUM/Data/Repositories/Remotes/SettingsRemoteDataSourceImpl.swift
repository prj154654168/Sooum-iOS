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
}
