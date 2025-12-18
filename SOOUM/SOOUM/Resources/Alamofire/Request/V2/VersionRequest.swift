//
//  VersionRequest.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

enum VersionRequest: BaseRequest {
    
    case version
    
    var path: String {
        return "/api/version/IOS"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters {
        return ["version": Info.appVersion]
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var authorizationType: AuthorizationType {
        return .none
    }
    
    var serverEndpoint: String {
        return "https://test-core.sooum.org:555"
    }
    
    func asURLRequest() throws -> URLRequest {
        
        // TODO: 앱 심사 중 사용할 url
        // if let url = URL(string: Constants.endpoint)?.appendingPathComponent(self.path) {
        if let url = URL(string: self.serverEndpoint)?.appendingPathComponent(self.path) {
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
            
            let encoded = try self.encoding.encode(request, with: self.parameters)
            return encoded
        } else {
            return .init(url: URL(string: "")!)
        }
    }
}
