//
//  TagCardInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/18/25.
//

import Alamofire

struct TagCardInfoResponse {
    
    let cardInfos: [ProfileCardInfo]
    let isFavorite: Bool
}

extension TagCardInfoResponse: EmptyResponse {
    
    static func emptyValue() -> TagCardInfoResponse {
        TagCardInfoResponse(cardInfos: [], isFavorite: false)
    }
}

extension TagCardInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case cardInfos = "cardContents"
        case isFavorite
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cardInfos = try container.decode([ProfileCardInfo].self, forKey: .cardInfos)
        self.isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
    }
}
