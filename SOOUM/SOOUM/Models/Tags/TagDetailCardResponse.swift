//
//  TagDetailCardResponse.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import Foundation

// MARK: - TagDetailCardResponse
struct TagDetailCardResponse: Codable {
    
    // MARK: - Embedded
    struct Embedded: Codable {
        let tagFeedCardDtoList: [TagFeedCard]
    }

    // MARK: - TagFeedCardDtoList
    struct TagFeedCard: Codable {
        let id, content, createdAt: String
        let likeCnt, commentCnt: Int
        let backgroundImgURL: Next
        let font: Font
        let fontSize: FontSize
        let distance: Double?
        let links: TagFeedCardDtoListLinks
        let isLiked, isCommentWritten: Bool

        enum CodingKeys: String, CodingKey {
            case id, content, createdAt, likeCnt, commentCnt
            case backgroundImgURL = "backgroundImgUrl"
            case font, fontSize, distance
            case links = "_links"
            case isLiked, isCommentWritten
        }
    }

    // MARK: - Next
    struct Next: Codable {
        let href: String
    }

    enum Font: String, Codable {
        case pretendard = "PRETENDARD"
    }

    enum FontSize: String, Codable {
        case big = "BIG"
    }

    // MARK: - TagFeedCardDtoListLinks
    struct TagFeedCardDtoListLinks: Codable {
        let detail: Next
    }

    // MARK: - TagDetailCardResponseLinks
    struct TagDetailCardResponseLinks: Codable {
        let next: Next
    }

    // MARK: - Status
    struct Status: Codable {
        let httpCode: Int
        let httpStatus, responseMessage: String
    }
    
    let embedded: Embedded
    let links: TagDetailCardResponseLinks
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
}
