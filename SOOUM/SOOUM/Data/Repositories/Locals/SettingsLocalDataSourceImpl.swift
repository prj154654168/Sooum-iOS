//
//  SettingsLocalDataSourceImpl.swift
//  SOOUM
//
//  Created by 오현식 on 11/17/25.
//

import RxSwift

class SettingsLocalDataSourceImpl: SettingsLocalDataSource {
    
    private let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func notificationStatus() -> Bool {
        
        return self.provider.pushManager.notificationStatus
    }
    
    func switchNotification(on: Bool) -> Observable<Error?> {
        
        return self.provider.pushManager.switchNotification(on: on)
    }
    
    func coordinate() -> Coordinate {
        
        return self.provider.locationManager.coordinate
    }
    
    func hasPermission() -> Bool {
        
        return self.provider.locationManager.hasPermission
    }
    
    func requestLocationPermission() {
        
        self.provider.locationManager.requestLocationPermission()
    }
    
    func checkLocationAuthStatus() -> AuthStatus {
        
        return self.provider.locationManager.checkLocationAuthStatus()
    }
}
