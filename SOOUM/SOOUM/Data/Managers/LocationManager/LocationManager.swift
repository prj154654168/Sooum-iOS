//
//  LocationManager.swift
//  SOOUM
//
//  Created by 오현식 on 9/24/24.
//

import CoreLocation
import UIKit


enum AuthStatus {
    case notDetermined
    case restricted
    case denied
    case authorizedAlways
    case authorizedWhenInUse
}

protocol LocationManagerDelegate: AnyObject {
    
    var coordinate: Coordinate { get }
    var hasPermission: Bool { get }
    func requestLocationPermission()
    func checkLocationAuthStatus() -> AuthStatus
}

class LocationManager: CompositeManager<LocationManagerConfigruation> {
    private(set) var locationManager: CLLocationManager
    private(set) var locationAuthStatus: AuthStatus
    
    var coordinate: Coordinate {
        let coordinate = SimpleDefaults.shared.loadLocation()
        return coordinate
    }
    
    var hasPermission: Bool {
        return self.checkLocationAuthStatus() == .authorizedAlways ||
            self.checkLocationAuthStatus() == .authorizedWhenInUse
    }
    
    override init(provider: ManagerTypeDelegate, configure: LocationManagerConfigruation) {
        self.locationAuthStatus = .notDetermined
        self.locationManager = CLLocationManager()
        
        super.init(provider: provider, configure: configure)
        
        self.locationManager.delegate = self
        self.updateLocationAuthStatus()
    }
}

extension LocationManager: LocationManagerDelegate {
    
    /// 사용자에게 위치 권한을 요청합니다.
    func requestLocationPermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func checkLocationAuthStatus() -> AuthStatus {
        return self.convertLocationAuthStatus(self.locationManager.authorizationStatus)
    }
    
    private func updateLocationAuthStatus() {
        let authStatus = self.convertLocationAuthStatus(self.locationManager.authorizationStatus)
        
        guard self.locationAuthStatus != authStatus else { return }
        
        self.locationAuthStatus = authStatus
        
        Log.debug("Change location auth status", authStatus)
        NotificationCenter.default.post(name: .changedLocationAuthorization, object: nil)
        
        switch authStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
        default:
            self.locationManager.stopUpdatingLocation()
            SimpleDefaults.shared.initLocation()
        }
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

extension LocationManager: CLLocationManagerDelegate {
    
    /// 위치 정보 업데이트
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        let convert: Coordinate = .init(
            latitude: coordinate.latitude.description,
            longitude: coordinate.longitude.description
        )
        SimpleDefaults.shared.saveLocation(convert)
        
        Log.debug("Update location coordinate: \(coordinate)")
    }
    
    /// 오류 처리
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.error("Update location error", error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.updateLocationAuthStatus()
    }
}
