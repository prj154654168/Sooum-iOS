//
//  BlockUsersInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Alamofire

struct BlockUsersInfoResponse {
    
    let blockUsers: [BlockUserInfo]
}

extension BlockUsersInfoResponse: EmptyResponse {
    
    static func emptyValue() -> BlockUsersInfoResponse {
        BlockUsersInfoResponse(blockUsers: [])
    }
}

extension BlockUsersInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case blockUsers
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.blockUsers = try singleContainer.decode([BlockUserInfo].self)
    }
}
