//
//  MockCoreLocation.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/3/25.
//

@testable import SOOUM_Dev

import CoreLocation


class MockCoreLocation: CLLocationManager {
    
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var mockLocation: CLLocation?
    var mockError: Error?
    
    var startUpdatingLocationCalled = false
    var stopUpdatingLocationCalled = false
    var requestWhenInUseAuthorizationCalled = false
    
    override var authorizationStatus: CLAuthorizationStatus {
        return self.mockAuthorizationStatus
    }
    
    override func startUpdatingLocation() {
        self.startUpdatingLocationCalled = true
    }
    
    override func stopUpdatingLocation() {
        self.stopUpdatingLocationCalled = true
    }
    
    override func requestWhenInUseAuthorization() {
        self.requestWhenInUseAuthorizationCalled = true
    }
    
    func updateLocation() {
        if let location = self.mockLocation {
            self.delegate?.locationManager?(self, didUpdateLocations: [location])
        }
    }
    
    func updateAuthorization() {
        self.delegate?.locationManagerDidChangeAuthorization?(self)
    }
    
    func updateError() {
        if let error = self.mockError {
            self.delegate?.locationManager?(self, didFailWithError: error)
        }
    }
}
