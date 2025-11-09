//
//  SettingsUserCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Foundation

import RxSwift

class SettingsUserCaseImpl: SettingsUserCase {
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func issue() -> Observable<TransferCodeInfo> {
        
        return self.repository.issue().map(\.transferInfo)
    }
    
    func enter(code: String, encryptedDeviceId: String) -> Observable<Bool> {
        
        return self.repository.enter(code: code, encryptedDeviceId: encryptedDeviceId).map { $0 == 200 }
    }
    
    func update() -> Observable<TransferCodeInfo> {
        
        return self.repository.update().map(\.transferInfo)
    }
    
    func blockUsers(lastId: String?) -> Observable<[BlockUserInfo]> {
        
        return self.repository.blockUsers(lastId: lastId).map(\.blockUsers)
    }
}
