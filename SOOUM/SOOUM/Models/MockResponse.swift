//
//  MockResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/23/24.
//

import Foundation


// MARK: - ServerResponse
struct MockResponse: Codable {
    let embedded: Embedded
    let links: Links
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
}

// MARK: - Embedded
struct Embedded: Codable {
    let latestFeedCardDtoList: [LatestFeedCardDto]
}

// MARK: - LatestFeedCardDto
struct LatestFeedCardDto: Codable {
    let id: Int64
    let storyExpirationTime: String
    let content: String
    let createdAt: String
    let likeCnt: Int
    let commentCnt: Int
    let backgroundImgUrl: BackgroundImgUrl
    let font: String
    let fontSize: String
    let distance: String?
    let links: CardLinks
    let isStory: Bool
    let isLiked: Bool
    let isCommentWritten: Bool

    enum CodingKeys: String, CodingKey {
        case id, storyExpirationTime, content, createdAt, likeCnt, commentCnt, backgroundImgUrl, font, fontSize, distance
        case links = "_links"
        case isStory, isLiked, isCommentWritten
    }
}

// MARK: - BackgroundImgUrl
struct BackgroundImgUrl: Codable {
    let href: String
}

// MARK: - CardLinks
struct CardLinks: Codable {
    let detail: Detail
}

// MARK: - Detail
struct Detail: Codable {
    let href: String
}

// MARK: - Links
struct Links: Codable {
    let next: Next
}

// MARK: - Next
struct Next: Codable {
    let href: String
}

// MARK: - Status
struct Status: Codable {
    let httpCode: Int
    let httpStatus: String
    let responseMessage: String
}
