//
//  distanceCardResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import Foundation

import Alamofire


struct DistanceCardResponse: Codable {
    let embedded: DistanceCardEmbedded
    let links: Next
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
}

struct DistanceCardEmbedded: Codable {
    let cards: [Card]
    
    enum CodingKeys: String, CodingKey {
        case cards = "distanceCardDtoList"
    }
}

extension DistanceCardResponse {
    
    init() {
        self.embedded = .init(cards: [])
        self.links = .init()
        self.status = .init()
    }
}

extension DistanceCardResponse: EmptyResponse {
    static func emptyValue() -> DistanceCardResponse {
        DistanceCardResponse.init()
    }
}


