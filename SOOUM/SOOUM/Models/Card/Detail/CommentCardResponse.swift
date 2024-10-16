//
//  CommentCardResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/9/24.
//

import Foundation

struct CommentCardResponse: Codable {
    let embedded: CommentCardEmbedded
    let links: Next
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
}

extension CommentCardResponse: EmptyInitializable {
    static func empty() -> CommentCardResponse {
        return .init(
            embedded: .init(commentCards: []),
            links: .init(),
            status: .init()
        )
    }
}

struct CommentCardEmbedded: Codable {
    let commentCards: [Card]
    
    enum CodingKeys: String, CodingKey {
        case commentCards = "commentCardsInfoList"
    }
}
