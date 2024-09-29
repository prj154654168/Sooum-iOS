//
//  LatestCardResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import Foundation


struct LatestCardResponse: Codable {
    let embedded: LatestCardEmbedded
    let links: CardURL
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
}

struct LatestCardEmbedded: Codable {
    let cards: [Card]
    
    enum CodingKeys: String, CodingKey {
        case cards = "latestFeedCardDtoList"
    }
}
