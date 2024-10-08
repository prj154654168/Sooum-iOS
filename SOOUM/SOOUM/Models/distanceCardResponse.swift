//
//  distanceCardResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import Foundation


struct DistanceCardResponse: Codable {
    let embedded: DistanceCardEmbedded
    let links: CardURL
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
}

extension DistanceCardResponse: EmptyInitializable {
    static func empty() -> DistanceCardResponse {
        return .init(
            embedded: .init(cards: []),
            links: .init(next: .init(url: "")),
            status: .init(httpCode: 0, httpStatus: "", responseMessage: "")
        )
    }
}

struct DistanceCardEmbedded: Codable {
    let cards: [Card]
    
    enum CodingKeys: String, CodingKey {
        case cards = "distanceCardDtoList"
    }
}
