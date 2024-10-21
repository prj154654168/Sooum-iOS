//
//  PopularCardResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import Foundation


struct PopularCardResponse: Codable {
    let embedded: PopularCardEmbedded
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case status
    }
}

extension PopularCardResponse: EmptyInitializable {
    static func empty() -> PopularCardResponse {
        return .init(
            embedded: .init(cards: []),
            status: .init()
        )
    }
}

struct PopularCardEmbedded: Codable {
    let cards: [Card]
    
    enum CodingKeys: String, CodingKey {
        case cards = "popularCardRetrieveList"
    }
}
