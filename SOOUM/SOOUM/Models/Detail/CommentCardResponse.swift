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

struct CommentCardEmbedded: Codable {
    let commentCardsInfoList: [CommentCard]
}

struct CommentCard: CardProtocol, Codable {
    
    let id: String
    let content: String
    let createdAt: Date
    let likeCnt: Int
    let commentCnt: Int
    var backgroundImgURL: URLString
    let font: Font
    let fontSize: String
    let distance: Double?
    let links: Detail
    let isLiked: Bool
    let isCommentWritten: Bool
    var storyExpirationTime: Date?
    var isStory: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, content, createdAt, likeCnt, commentCnt, font, fontSize, distance
        case links = "_links"
        case backgroundImgURL = "backgroundImgUrl"
        case isLiked, isCommentWritten
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

struct DetailLink: Codable {
    let detail: Next
}
