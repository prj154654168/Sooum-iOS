//
//  TagRequest.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import Foundation

import Alamofire

enum TagRequest: BaseRequest {
    
    // 연관 태그
    case related(keyword: String, size: Int)
    
    case favorites
    case updateFavorite(tagId: String, isFavorite: Bool)
    case ranked
    case tagCards(tagId: String, lastId: String?)

    var path: String {
        switch self {
        case let .related(_, size):
            return "/api/tags/related/\(size)"
            
        case .favorites:
            
            return "/api/tags/favorite"
        case let .updateFavorite(tagId, _):
            
            return "/api/tags/\(tagId)/favorite"
        case .ranked:
            
            return "/api/tags/rank"
        case let .tagCards(tagId, lastId):
            
            if let lastId = lastId {
                return "/api/tags/\(tagId)/cards/\(lastId)"
            } else {
                return "/api/tags/\(tagId)/cards"
            }
        }
    }
        
    var method: HTTPMethod {
        switch self {
        case .related:
            return .post
        case let .updateFavorite(_, isFavorite):
            return isFavorite ? .post : .delete
        default:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case let .related(keyword, _):
            return ["tag": keyword]
        default:
            return [:]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .related:
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

            let encoded = try encoding.encode(request, with: self.parameters)
            return encoded
        } else {
            return URLRequest(url: URL(string: "")!)
        }
    }
}
