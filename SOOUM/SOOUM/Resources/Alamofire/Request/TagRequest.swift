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
    case tagInfo(tagID: String)
    case tagCard(tagID: String)
    case addFavorite(tagID: String)
    case deleteFavorite(tagID: String)

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
            
        case .search:
            return "/tags/search"
            
        case let .tagInfo(tagID):
            return "/tags/\(tagID)/summary"
            
        case let .tagCard(tagID):
            return "/cards/tags/\(tagID)"
            
        case let .addFavorite(tagID):
            return "/tags/\(tagID)/favorite"

        case let .deleteFavorite(tagID):
            return "/tags/\(tagID)/favorite"
        }
    }
        
    var method: HTTPMethod {
        switch self {
        case .addFavorite(_):
            return .post
            
        case .deleteFavorite(_):
            return .delete
            
        default:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case let .favorite(lastId):
            if let lastId = lastId {
                return ["last": lastId]
            } else {
                return [:]
            }
            
        case let .search(keyword):
            return ["keyword": keyword, "size": 20]
            
        default:
            return [:]
        }
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.queryString
    }
    
    var authorizationType: AuthorizationType {
        return .access
    }
    
    var version: APIVersion {
        return .v1
    }
        
    func asURLRequest() throws -> URLRequest {

        let pathWithAPIVersion = self.path + self.version.rawValue
        if let url = URL(string: Constants.endpoint)?.appendingPathComponent(pathWithAPIVersion) {
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
