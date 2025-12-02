//
//  SettingsUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Foundation

import RxSwift

class SettingsUseCaseImpl: SettingsUseCase {
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository) {
        self.repository = repository
    }
    
    func rejoinableDate() -> Observable<RejoinableDateInfo> {
        
        return self.repository.rejoinableDate().map(\.rejoinableDate)
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
    
    func notificationStatus() -> Bool {
        
        return self.repository.notificationStatus()
    }
    
    func switchNotification(on: Bool) -> Observable<Void> {
        
        return self.repository.switchNotification(on: on).map { _ in () }
    }
    
    func coordinate() -> Coordinate {
        
        return self.repository.coordinate()
    }
    
    func hasPermission() -> Bool {
        
        return self.repository.hasPermission()
    }
    
    func requestLocationPermission() {
        
        self.repository.requestLocationPermission()
    }
    
    func checkLocationAuthStatus() -> AuthStatus {
        
        return self.repository.checkLocationAuthStatus()
    }
}
