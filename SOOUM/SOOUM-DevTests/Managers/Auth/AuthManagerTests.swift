//
//  AuthManagerTests.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/1/25.
//

@testable import SOOUM_Dev
import XCTest


class AuthManagerTests: XCTestCase {
    
    private var authManager: MockAuthManager!
    
    override func setUp() {
        super.setUp()
        
        self.authManager = (MockManagerProviderContainer().authManager as! MockAuthManager)
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.authManager = nil
    }
    
    func testHasToken() throws {
        
        XCTAssertTrue(self.authManager.hasToken)
    }
    
    func testRSAEncryption() throws {
        
        let secKey = self.authManager.convertPEMToSecKey(pemString: self.authManager.publicKey)
        XCTAssertNotNil(secKey)
        
        let encryptUUID = self.authManager.encryptUUIDWithPublicKey(publicKey: secKey!)
        XCTAssertNotNil(encryptUUID)
    }
    
    func testJoin() throws {
        
        self.authManager.shouldJoinSuccess = true
        let expectation = XCTestExpectation(description: "Join completed")
        
        self.authManager.join()
            .subscribe(onNext: { success in
                
                XCTAssertTrue(success)
                expectation.fulfill()
            })
            .disposed(by: self.authManager.disposeBag)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCertification() throws {
        
        self.authManager.shouldCertificationSuccess = true
        let expectation = XCTestExpectation(description: "Certification completed")
        
        self.authManager.certification()
            .subscribe(onNext: { success in
                
                XCTAssertTrue(success)
                expectation.fulfill()
            })
            .disposed(by: self.authManager.disposeBag)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testReAuthenticate() throws {
        
        let accessToken = self.authManager.authInfo.token.accessToken
        XCTAssertNotNil(accessToken)
        
        let expectation: XCTestExpectation = expectation(description: "waiting...")
        self.authManager.reAuthenticate(accessToken) { _ in
            expectation.fulfill()
        }
        XCTAssertTrue(self.authManager.isReAuthenticating)
        
        var afterRequestBlocked: Bool = false
        self.authManager.reAuthenticate(accessToken) { _ in
            afterRequestBlocked = true
        }
        XCTAssertTrue(afterRequestBlocked)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testInitializeAuthInfo() throws {
        
        self.authManager.initializeAuthInfo()
        XCTAssertFalse(self.authManager.hasToken)
    }
    
    func testUpdateToken() throws {
        
        let accessToken = self.authManager.authInfo.token.accessToken
        let refreshToken = self.authManager.authInfo.token.refreshToken
        
        let new = Token(accessToken: "new-access-token", refreshToken: "new-refresh-token")
        self.authManager.updateTokens(new)
        XCTAssertNotEqual(accessToken, self.authManager.authInfo.token.accessToken)
        XCTAssertNotEqual(refreshToken, self.authManager.authInfo.token.refreshToken)
        
        let origin = Token(accessToken: accessToken, refreshToken: refreshToken)
        self.authManager.updateTokens(origin)
        XCTAssertEqual(accessToken, self.authManager.authInfo.token.accessToken)
        XCTAssertEqual(refreshToken, self.authManager.authInfo.token.refreshToken)
    }
    
    func testAuthPayload() throws {
        
        let payloadByAccess = self.authManager.authPayloadByAccess()
        let payloadByRefresh = self.authManager.authPayloadByRefresh()
        XCTAssertNotNil(payloadByAccess)
        XCTAssertNotNil(payloadByRefresh)
        XCTAssertTrue(payloadByAccess["Authorization"]?.hasSuffix(self.authManager.authInfo.token.accessToken) == true)
        XCTAssertTrue(payloadByRefresh["Authorization"]?.hasSuffix(self.authManager.authInfo.token.refreshToken) == true)
    }
}
