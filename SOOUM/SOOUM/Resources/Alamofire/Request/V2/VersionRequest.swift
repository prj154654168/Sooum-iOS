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
        #if PRODUCTION
        /// 구버전 업데이트를 위한 API
        return "app/version/ios/v2"
        #elseif DEVELOP
        return "/api/version/IOS"
        #endif
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
            
            let encoded = try self.encoding.encode(request, with: self.parameters)
            return encoded
        } else {
            return .init(url: URL(string: "")!)
        }
    }
}
