//
//  MockLocationManager.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/3/25.
//

@testable import SOOUM_Dev

import CoreLocation


class MockLocationManager: CompositeManager<LocationManagerConfigruation>, LocationManagerDelegate {
    
    let mockCoreLocation: MockCoreLocation
    
    var coordinate: Coordinate {
        return Coordinate()
    }
    
    override init(provider: ManagerTypeDelegate, configure: LocationManagerConfigruation) {
        self.mockCoreLocation = MockCoreLocation()
        
        super.init(provider: provider, configure: configure)
    }
    
    func requestLocationPermission() {
        self.mockCoreLocation.requestWhenInUseAuthorization()
    }
    
    func checkLocationAuthStatus() -> AuthStatus {
        return self.convertLocationAuthStatus(self.mockCoreLocation.authorizationStatus)
    }
    
    private func convertLocationAuthStatus(_ authStatus: CLAuthorizationStatus) -> AuthStatus {
        switch authStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorizedAlways:
            return .authorizedAlways
        case .authorizedWhenInUse:
            return .authorizedWhenInUse
        @unknown default:
            return .notDetermined
        }
    }
}

extension MockLocationManager {
    
    func setAuthorizationStatus(_ status: CLAuthorizationStatus) {
        self.mockCoreLocation.mockAuthorizationStatus = status
    }
}
