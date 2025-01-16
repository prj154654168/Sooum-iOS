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
    
    func locationManager(
        _ manager: LocationManager,
        didUpdateCoordinate coordinate: CLLocationCoordinate2D
    )
    func locationManager(_ manager: LocationManager, didChangeAuthStatus status: AuthStatus)
    func locationManager(_ manager: LocationManager, didFailWithError error: Error)
}

class LocationManager: CompositeManager {
    
    private(set) var locationAuthStatus: AuthStatus
    private(set) var locationManager: CLLocationManager
    
    weak var delegate: LocationManagerDelegate?
    
    var coordinate: Coordinate {
        let coordinate = SimpleDefaults.shared.loadLocation()
        return coordinate
    }
    
    override init(provider: ManagerProviderType) {
        self.locationAuthStatus = .notDetermined
        self.locationManager = CLLocationManager()
        
        super.init(provider: provider)
        
        self.locationManager.delegate = self
        self.updateLocationAuthStatus()
    }
}

extension LocationManager {
    
    /// 사용자에게 위치 권한을 요청합니다.
    func requestLocationPermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func checkLocationAuthStatus() -> AuthStatus {
        return self.convertLocationAuthStatus(self.locationManager.authorizationStatus)
    }
    
    private func updateLocationAuthStatus() {
        let authStatus = self.convertLocationAuthStatus(self.locationManager.authorizationStatus)
        
        self.locationAuthStatus = authStatus
        self.delegate?.locationManager(self, didChangeAuthStatus: authStatus)
        
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
        self.delegate?.locationManager(self, didUpdateCoordinate: coordinate)
    }
    
    /// 오류 처리
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.locationManager(self, didFailWithError: error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocationAuthStatus()
    }
}
