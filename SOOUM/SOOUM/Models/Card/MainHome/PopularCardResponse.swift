//
//  PopularCardResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import Foundation

import Alamofire


struct PopularCardResponse: Codable {
    let embedded: PopularCardEmbedded
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case status
    }
}

struct PopularCardEmbedded: Codable {
    let cards: [Card]
    
    enum CodingKeys: String, CodingKey {
        case cards = "popularCardRetrieveList"
    }
}

extension PopularCardResponse {
    
    init() {
        self.embedded = .init(cards: [])
        self.status = .init()
    }
}

extension PopularCardResponse: EmptyResponse {
    static func emptyValue() -> PopularCardResponse {
        PopularCardResponse.init()
    }
}


