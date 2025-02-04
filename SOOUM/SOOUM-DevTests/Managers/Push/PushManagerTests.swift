//
//  PushManagerTests.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/2/25.
//

@testable import SOOUM_Dev
import XCTest


class PushManagerTests: XCTestCase {
    
    private var pushManager: MockPushManager!
    
    override func setUp() {
        super.setUp()
        
        self.pushManager = (MockManagerProviderContainer().pushManager as! MockPushManager)
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.pushManager = nil
    }
    
    func testWindow() throws {
        
        XCTAssertNotNil(self.pushManager.window)
    }
    
    func testSetupRootViewController() throws {
        
        let notificationInfo = NotificationInfo([
            "notificationType": "COMMENT_LIKE",
            "notificationId": "6454123124",
            "targetCardId": "667730503722226338"
        ])
        
        self.pushManager.setupRootViewController(notificationInfo, terminated: false)
        XCTAssertNotNil(self.pushManager.notiInfo)
    }
    
    func testSwitchNotificationTurnOn() throws {
        
        let expectation = self.expectation(description: "Turn on")
        self.pushManager.switchNotification(isOn: true) { [weak self] error in
            
            XCTAssertNil(error)
            XCTAssertTrue(self?.pushManager.notificationStatus ?? false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSwitchNotificationTurnOff() throws {
        
        let expectation = self.expectation(description: "Turn off")
        self.pushManager.switchNotification(isOn: false) { [weak self] error in
            
            XCTAssertNil(error)
            XCTAssertFalse(self?.pushManager.notificationStatus ?? true)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
