//
//  LocationManagerTests.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/3/25.
//

@testable import SOOUM_Dev
import XCTest


class LocationManagerTests: XCTestCase {
    
    private var locationManager: MockLocationManager!
    
    override func setUp() {
        super.setUp()
        
        self.locationManager = (MockManagerProviderContainer().locationManager as! MockLocationManager)
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.locationManager = nil
    }
    
    func testRequestLocationPermission() {
        
        self.locationManager.requestLocationPermission()
        
        XCTAssertTrue(self.locationManager.mockCoreLocation.requestWhenInUseAuthorizationCalled)
    }
    
    func testCheckLocationAuthStatus() {
        
        self.locationManager.setAuthorizationStatus(.authorizedWhenInUse)
        
        let status = self.locationManager.checkLocationAuthStatus()
        
        XCTAssertEqual(status, .authorizedWhenInUse)
    }
    
    func testChangeAuthorizationStatus() {
        
        self.locationManager.setAuthorizationStatus(.authorizedAlways)
        
        self.locationManager.mockCoreLocation.updateAuthorization()
        
        XCTAssertEqual(self.locationManager.checkLocationAuthStatus(), .authorizedAlways)
    }
}
