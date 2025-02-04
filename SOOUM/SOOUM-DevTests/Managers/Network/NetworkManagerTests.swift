//
//  NetworkManagerTests.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/3/25.
//

@testable import SOOUM_Dev
import XCTest


class NetworkManagerTests: XCTestCase {
    
    private var networkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        
        self.networkManager = (MockManagerProviderContainer().networkManager as! MockNetworkManager)
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.networkManager = nil
    }
    
    func testRequestForSuccess() {
        
        let expectation = XCTestExpectation(description: "Request should succeed")
        let mockResponse = MockResponse(id: "1", name: "test")
        self.networkManager.mockSession.setupSuccessResponse(mockResponse)
        
        self.networkManager.request(MockResponse.self, request: MockRequest.mock)
            .withUnretained(self)
            .subscribe(
                onNext: { object, response in
                    XCTAssertEqual(response.id, mockResponse.id)
                    XCTAssertEqual(response.name, mockResponse.name)
                    XCTAssertTrue(object.networkManager.mockSession.requestCalled)
                    expectation.fulfill()
                },
                onError: { error in
                    XCTFail("Should not fail with error: \(error)")
                }
            )
            .disposed(by: self.networkManager.disposeBag)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRequestForFailure() {
        
        let expectation = XCTestExpectation(description: "Request should fail")
        let mockError = NSError(domain: "test", code: 400, userInfo: nil)
        self.networkManager.mockSession.setupErrorResponse(statusCode: 400, error: mockError)
        
        self.networkManager.request(MockResponse.self, request: MockRequest.mock)
            .subscribe(
                with: self,
                onNext: { _, _ in
                    XCTFail("Should not success")
                },
                onError: { object, error in
                    XCTAssertEqual((error as NSError).code, mockError.code)
                    XCTAssertTrue(object.networkManager.mockSession.requestCalled)
                    expectation.fulfill()
                }
            )
            .disposed(by: self.networkManager.disposeBag)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpload() {
        
        let expectation = XCTestExpectation(description: "Upload should succeed")
        let testData = "test".data(using: .utf8)!
        
        self.networkManager.upload(testData, to: "http://test.com")
            .withUnretained(self)
            .subscribe(
                onNext: { object, result in
                    switch result {
                    case .success:
                        XCTAssertTrue(object.networkManager.mockSession.uploadCalled)
                        expectation.fulfill()
                    case .failure:
                        XCTFail("Should not fail")
                    }
                },
                onError: { error in
                    XCTFail("Should not fail with error: \(error)")
                }
            )
            .disposed(by: self.networkManager.disposeBag)
        
        wait(for: [expectation], timeout: 1.0)
    }
}
