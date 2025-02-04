//
//  MockManagerProviderContainerTests.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/1/25.
//

@testable import SOOUM_Dev
import XCTest

import RxSwift


final class MockManagerProviderContainerTests: XCTestCase {
    
    private var container: ManagerProviderType!
    private var provider: ManagerTypeDelegate!
    
    override func setUp() {
        super.setUp()
        
        self.container = MockManagerProviderContainer()
        self.provider = MockManagerProvider()
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.container = nil
        self.provider = nil
    }
    
    func testManagerProviderContainerInitialization() throws {
        
        // Then
        XCTAssertNotNil(self.container.authManager)
        XCTAssertNotNil(self.container.pushManager)
        XCTAssertNotNil(self.container.networkManager)
        XCTAssertNotNil(self.container.locationManager)
    }
    
    func testManagerProviderInitialization() throws {
        
        // Then
        XCTAssertNotNil(self.provider.authManager)
        XCTAssertNotNil(self.provider.pushManager)
        XCTAssertNotNil(self.provider.networkManager)
        XCTAssertNotNil(self.provider.locationManager)
    }
    
    func testManagerProviderHasSameInstance() throws {
        
        // Then
        XCTAssertTrue(self.provider.authManager === self.provider.authManager)
        XCTAssertTrue(self.provider.pushManager === self.provider.pushManager)
        XCTAssertTrue(self.provider.networkManager === self.provider.networkManager)
        XCTAssertTrue(self.provider.locationManager === self.provider.locationManager)
    }
}
