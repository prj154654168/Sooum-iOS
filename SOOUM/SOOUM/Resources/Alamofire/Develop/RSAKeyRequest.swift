//
//  RSAKeyRequest.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

import Alamofire

enum RSAKeyRequest: BaseRequest {

    case getPublicKey

    var path: String {
        return "/users/key"
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: Parameters {
        return [:]
    }

    var encoding: ParameterEncoding {
        return URLEncoding.queryString
    }

    func asURLRequest() throws -> URLRequest {
        if let url = URL(string: "http://49.172.40.78:8080")?.appendingPathComponent(self.path) {
            print("\(type(of: self)) - \(#function) url:", url)
            var request = URLRequest(url: url)
            request.method = self.method

            let encoded = try encoding.encode(request, with: self.parameters)
            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}
