//
//  TransferAccountUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class TransferAccountUseCaseImpl: TransferAccountUseCase {
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func issue() -> Observable<TransferCodeInfo> {
        
        return self.repository.issue().map(\.transferInfo)
    }
    
    func enter(code: String, encryptedDeviceId: String) -> Observable<Bool> {
        
        return self.repository.enter(
            code: code,
            encryptedDeviceId: encryptedDeviceId
        )
        .map { $0 == 200 }
    }
}
