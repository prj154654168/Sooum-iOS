//
//  SignupRequest.swift
//  SOOUM-Dev
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

import Alamofire

enum SignupRequest: BaseRequest {
    case signup(
        encryptedDeviceId: String,
        firebaseToken: String,
        isAllowNotify: Bool
//        isAllowTermOne: Bool,
//        isAllowTermTwo: Bool,
//        isAllowTermThree: Bool
    )

    var path: String {
        return "/users/sign-up"
    }

    var method: HTTPMethod {
        return .post
    }

    var parameters: Parameters {
        switch self {
        case let .signup(
            encryptedDeviceId,
            firebaseToken,
            isAllowNotify
//            isAllowTermOne,
//            isAllowTermTwo,
//            isAllowTermThree
        ):
            return [
                "member": [
                    "encryptedDeviceId": encryptedDeviceId,
                    "deviceType": "IOS",
                    "firebaseToken": firebaseToken,
                    "isAllowNotify": isAllowNotify
                ],
                "policy": [
                    "isAllowTermOne": true, // isAllowTermOne,
                    "isAllowTermTwo": true, // isAllowTermTwo,
                    "isAllowTermThree": true // isAllowTermThree
                ]
            ]
        }
    }

    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }

    func asURLRequest() throws -> URLRequest {
//        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(self.path) {
        if let url = URL(string: "http://49.172.40.78:8080")?.appendingPathComponent(self.path) {
            var request = URLRequest(url: url)
            request.method = self.method
            request.setValue(
                Constants.ContentType.json.rawValue,
                forHTTPHeaderField: Constants.HTTPHeader.contentType.rawValue
            )
            request.setValue(
                Constants.ContentType.json.rawValue,
                forHTTPHeaderField: Constants.HTTPHeader.acceptType.rawValue
            )
            let encoded = try encoding.encode(request, with: self.parameters)
            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}
