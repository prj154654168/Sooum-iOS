//
//  WriteCardResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/6/25.
//

import Alamofire

struct WriteCardResponse {
    
    let cardId: String
}

extension WriteCardResponse: EmptyResponse {
    
    static func emptyValue() -> WriteCardResponse {
        WriteCardResponse(cardId: "")
    }
}

extension WriteCardResponse: Decodable {
    
    enum CodingKeys: CodingKey {
        case cardId
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cardId = String(try container.decode(Int64.self, forKey: .cardId))
    }
}
