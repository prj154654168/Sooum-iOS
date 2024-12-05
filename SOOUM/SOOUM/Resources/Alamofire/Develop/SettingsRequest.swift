//
//  SettingsRequest.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import Foundation

import Alamofire


enum SettingsRequest: BaseRequest {

    case activate
    case commentHistory(lastId: String?)
    case transferCode(isUpdate: Bool)
    case transferMember(transferId: String, encryptedDeviceId: String)
    case resign(token: Token)
    

    var path: String {
        switch self {
        case .activate:
            return "/settings/status"
        case .commentHistory:
            return "/members/comment-cards"
        case .resign:
            return "/members"
        default:
            return "/settings/transfer"
        }
    }

    var method: HTTPMethod {
        switch self {
        case let .transferCode(isUpdate):
            return isUpdate ? .patch : .get
        case .transferMember:
            return .post
        case .resign:
            return .delete
        default:
            return .get
        }
    }

    var parameters: Parameters {
        switch self {
        case let .transferMember(transferId, encryptedDeviceId):
            return ["transferId": transferId, "encryptedDeviceId": encryptedDeviceId]
        case let .commentHistory(lastId):
            if let lastId = lastId {
                return ["lastId": lastId]
            } else {
                return [:]
            }
        case let .resign(token):
            return ["accessToken": token.accessToken, "refreshToken": token.refreshToken]
        default: return [:]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .transferMember, .resign:
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
            
            let authPayload = AuthManager.shared.authPayloadByAccess()
            let authKey = authPayload.keys.first! as String
            request.setValue(authPayload[authKey], forHTTPHeaderField: authKey)
            
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

