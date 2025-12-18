//
//  LocationUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class LocationUseCaseImpl: LocationUseCase {
    
    private let repository: SettingsRepository
    
    init(repository: SettingsRepository) {
        self.repository = repository
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
