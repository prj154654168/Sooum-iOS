//
//  TagRequest.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import Foundation

import Alamofire

enum TagRequest: BaseRequest {
    case favorite(last: String?)
    case recommend
    case search(keyword: String)
    
    var path: String {
        switch self {
        case let .favorite(last):
            if let last = last {
                return "/tags/favorites/\(last)"
            } else {
                return "/tags/favorites"
            }
            
        case .recommend:
            return "/tags/recommendation"
            
        case let .search(keyword):
            return "/tags/search"
        }
    }
        
    var method: HTTPMethod {
        switch self {
        case .favorite, .recommend, .search:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .favorite, .recommend:
            return [:]
        case let .search(keyword):
            return [
                "keyword": keyword,
                "size": 20
            ]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .favorite, .recommend, .search:
            return URLEncoding.queryString
        }
    }
    
    var authorizationType: AuthorizationType {
        switch self {
        case .favorite, .recommend, .search:
            return .access
        }
    }
        
    func asURLRequest() throws -> URLRequest {

        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(self.path) {
            var request = URLRequest(url: url)
            request.method = self.method
            
            switch self.authorizationType {
            case .access:
                let authPayload = AuthManager.shared.authPayloadByAccess()
                let authKey = authPayload.keys.first! as String
                request.setValue(authPayload[authKey], forHTTPHeaderField: authKey)
            default:
                break
            }
            
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
