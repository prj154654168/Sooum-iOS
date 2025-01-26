//
//  ConfigureRequest.swift
//  SOOUM
//
//  Created by JDeoks on 1/26/25.
//

import Foundation

import Alamofire


enum ConfigureRequest: BaseRequest {

    case appFlag
    

    var path: String {
        switch self {
        case .appFlag:
            "/app/version/flag"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .appFlag:
            return .get
        }
    }

    var parameters: Parameters {
        switch self {
        case .appFlag:
            return [:]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .appFlag:
            return URLEncoding.default
        }
    }
    
    var authorizationType: AuthorizationType {
        return .access
    }

    func asURLRequest() throws -> URLRequest {

        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(self.path) {
            var request = URLRequest(url: url)
            request.method = self.method
            
            request.setValue(self.authorizationType.rawValue, forHTTPHeaderField: "AuthorizationType")
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
