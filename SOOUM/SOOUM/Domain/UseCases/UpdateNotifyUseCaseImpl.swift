//
//  UpdateNotifyUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class UpdateNotifyUseCaseImpl: UpdateNotifyUseCase {
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func notificationStatus() -> Bool {
        
        return self.repository.notificationStatus()
    }
    
    func switchNotification(on: Bool) -> Observable<Void> {
        
        return self.repository.switchNotification(on: on).map { _ in }
    }
    
    func updateNotify(isAllowNotify: Bool) -> Observable<Bool> {
        
        return self.repository.updateNotify(isAllowNotify: isAllowNotify).map { $0 == 200 }
    }
}
