//
//  SummaryResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/9/24.
//

import Foundation

struct CardSummaryResponse: Codable {
    let cardSummary: CardSummary
    let status: Status

    enum CodingKeys: String, CodingKey {
        case cardSummary
        case status
    }
}

extension CardSummaryResponse {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Status.self, forKey: .status)
        
        let singleContainer = try decoder.singleValueContainer()
        self.cardSummary = try singleContainer.decode(CardSummary.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cardSummary, forKey: .cardSummary)
        try container.encode(status, forKey: .status)
    }
    
    init() {
        self.cardSummary = .init()
        self.status = .init()
    }
}

extension CardSummaryResponse: EmptyInitializable {
    static func empty() -> CardSummaryResponse {
        return .init()
    }
}

struct CardSummary: Codable {
    let commentCnt: Int
    let cardLikeCnt: Int
    let isLiked: Bool
}

extension CardSummary {
    init() {
        commentCnt = 0
        cardLikeCnt = 0
        isLiked = false
    }
}
