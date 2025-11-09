//
//  SettingsRepositoryImpl.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Foundation

import RxSwift

class SettingsRepositoryImpl: SettingsRepository {
    
    private let remoteDataSource: SettingsRemoteDataSource
    
    init(remoteDataSource: SettingsRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func issue() -> Observable<TransferCodeInfoResponse> {
        
        return self.remoteDataSource.issue()
    }
    
    func enter(code: String, encryptedDeviceId: String) -> Observable<Int> {
        
        return self.remoteDataSource.enter(code: code, encryptedDeviceId: encryptedDeviceId)
    }
    
    func update() -> Observable<TransferCodeInfoResponse> {
        
        return self.remoteDataSource.update()
    }
    
    func blockUsers(lastId: String?) -> Observable<BlockUsersInfoResponse> {
        
        return self.remoteDataSource.blockUsers(lastId: lastId)
    }
}
