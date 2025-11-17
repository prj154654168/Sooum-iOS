//
//  FavoriteTagInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/18/25.
//

import Alamofire

struct FavoriteTagInfoResponse {
    
    let tagInfos: [FavoriteTagInfo]
}

extension FavoriteTagInfoResponse: EmptyResponse {
    
    static func emptyValue() -> FavoriteTagInfoResponse {
        FavoriteTagInfoResponse(tagInfos: [])
    }
}

extension FavoriteTagInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case tagInfos = "favoriteTags"
    }
}
