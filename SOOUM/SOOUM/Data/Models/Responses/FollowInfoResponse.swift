//
//  FollowInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/6/25.
//

import Alamofire

struct FollowInfoResponse {
    
    let followInfos: [FollowInfo]
}

extension FollowInfoResponse: EmptyResponse {
    
    static func emptyValue() -> FollowInfoResponse {
        FollowInfoResponse(followInfos: [])
    }
}

extension FollowInfoResponse: Decodable {
    
    enum CodingKeys: CodingKey {
        case followInfos
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.followInfos = try singleContainer.decode([FollowInfo].self)
    }
}
