//
//  CommentCardResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/9/24.
//

import Foundation

import Alamofire


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

struct CommentCardEmbedded: Codable {
    let commentCards: [Card]
    
    enum CodingKeys: String, CodingKey {
        case commentCards = "commentCardsInfoList"
    }
}

extension CommentCardResponse {
    
    init() {
        self.embedded = .init(commentCards: [])
        self.links = .init()
        self.status = .init()
    }
}

extension CommentCardResponse: EmptyResponse {
    static func emptyValue() -> CommentCardResponse {
        CommentCardResponse.init()
    }
}
