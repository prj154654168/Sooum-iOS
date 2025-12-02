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
    private let localDataSource: SettingsLocalDataSource
    
    init(remoteDataSource: SettingsRemoteDataSource, localDataSource: SettingsLocalDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func rejoinableDate() -> Observable<RejoinableDateInfoResponse> {
        
        return self.remoteDataSource.rejoinableDate()
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
    
    func notificationStatus() -> Bool {
        
        return self.localDataSource.notificationStatus()
    }
    
    func switchNotification(on: Bool) -> Observable<Error?> {
        
        return  self.localDataSource.switchNotification(on: on)
    }
    
    func coordinate() -> Coordinate {
        
        return self.localDataSource.coordinate()
    }
    
    func hasPermission() -> Bool {
        
        return self.localDataSource.hasPermission()
    }
    
    func requestLocationPermission() {
        
        self.localDataSource.requestLocationPermission()
    }
    
    func checkLocationAuthStatus() -> AuthStatus {
        
        return self.localDataSource.checkLocationAuthStatus()
    }
}
