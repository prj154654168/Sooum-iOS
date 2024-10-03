//
//  SigninRequest.swift
//  SOOUM-Dev
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

import Alamofire

enum SigninRequest: BaseRequest {
    case login(encryptedDeviceId: String)

    var path: String {
        return "/users/login"
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: Parameters {
        switch self {
        case let .login(encryptedDeviceId):
            return ["encryptedDeviceId": encryptedDeviceId]
        }
    }

    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }

    func asURLRequest() throws -> URLRequest {
        if let url = URL(string: "http://49.172.40.78:8080")?.appendingPathComponent(self.path) {
            var request = URLRequest(url: url)
            request.method = self.method
            
            // Body에 데이터 추가
            request.httpBody = try? JSONSerialization.data(withJSONObject: self.parameters, options: [])
            
            request.setValue(
                Constants.ContentType.json.rawValue,
                forHTTPHeaderField: Constants.HTTPHeader.contentType.rawValue
            )
            request.setValue(
                Constants.ContentType.json.rawValue,
                forHTTPHeaderField: Constants.HTTPHeader.acceptType.rawValue
            )
        
            return request
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}
