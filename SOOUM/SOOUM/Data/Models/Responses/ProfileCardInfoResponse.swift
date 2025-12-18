//
//  ProfileCardInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/6/25.
//

import Alamofire

struct ProfileCardInfoResponse {
    
    let cardInfos: [ProfileCardInfo]
}

extension ProfileCardInfoResponse: EmptyResponse {
    
    static func emptyValue() -> ProfileCardInfoResponse {
        ProfileCardInfoResponse(cardInfos: [])
    }
}

extension ProfileCardInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case cardInfos = "cardContents"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cardInfos = try container.decode([ProfileCardInfo].self, forKey: .cardInfos)
    }
}
