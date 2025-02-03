//
//  MockAlamofire.swift
//  SOOUM-DevTests
//
//  Created by 오현식 on 2/2/25.
//

@testable import SOOUM_Dev

import Alamofire


struct MockResponse: Codable {
    let id: String
    let name: String
}

enum MockRequest: BaseRequest {
    case mock
    var method: HTTPMethod { .get }
    var path: String { "\test" }
    var parameters: Parameters { [:] }
    var encoding: ParameterEncoding { URLEncoding.default }
    var authorizationType: AuthorizationType { return .none }
    func asURLRequest() throws -> URLRequest { URLRequest(url: URL(string: "http://test.com")!) }
}

enum MockResponseData {
    static let success = """
    {
        "id": "1",
        "name": "test"
    }
    """
    static let error = """
    {
        "error": "Bad Request",
        "message": "Invalid request"
    }
    """
}

class MockSession {
    var mockStatusCode: Int = 200
    var mockData: Data?
    var mockError: Error?
    
    var requestCalled: Bool = false
    var uploadCalled: Bool = false
    
    func setupSuccessResponse<T: Encodable>(_ response: T) {
        self.mockStatusCode = 200
        self.mockData = try? JSONEncoder().encode(response)
        self.mockError = nil
    }
    func setupErrorResponse(statusCode: Int, error: Error? = nil) {
        self.mockStatusCode = statusCode
        self.mockData = nil
        self.mockError = error
    }
}
