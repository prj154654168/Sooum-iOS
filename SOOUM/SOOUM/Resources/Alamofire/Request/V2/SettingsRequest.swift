//
//  SettingsRequest.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Alamofire

enum SettingsRequest: BaseRequest {
    
    case transferIssue
    case transferEnter(code: String, encryptedDeviceId: String)
    case transferUpdate
    case blockUsers(lastId: String?)
    
    var path: String {
        switch self {
        case .transferIssue:
            return "/api/members/account/transfer-code"
        case .transferEnter:
            return "/api/members/account/transfer"
        case .transferUpdate:
            return "/api/members/account/transfer-code"
        case let .blockUsers(lastId):
            if let lastId = lastId {
                return "/api/blocks/\(lastId)"
            } else {
                return "/api/blocks"
            }
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .transferIssue, .blockUsers:
            return .get
        case .transferEnter:
            return .post
        case .transferUpdate:
            return .patch
        }
    }
    
    var parameters: Parameters {
        switch self {
        case let .transferEnter(code, encryptedDeviceId):
            return [
                "transferCode": code,
                "encryptedDeviceId": encryptedDeviceId,
                "deviceType": "IOS",
                "deviceModel": Info.deviceModel,
                "deviceOsVersion": Info.iOSVersion
            ]
        default:
            return [:]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .transferEnter:
            return JSONEncoding.default
        default:
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
            
            let encoded = try self.encoding.encode(request, with: self.parameters)
            return encoded
        } else {
            return .init(url: URL(string: "")!)
        }
    }
}
