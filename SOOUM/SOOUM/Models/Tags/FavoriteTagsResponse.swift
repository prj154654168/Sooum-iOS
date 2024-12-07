//
//  FavoriteTagsResponse.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import Foundation

// MARK: - FavoriteTagsResponse
struct FavoriteTagsResponse: Codable {
    
    // MARK: - Embedded
    struct Embedded: Codable {
        let favoriteTagList: [FavoriteTagList]
    }

    // MARK: - FavoriteTagList
    struct FavoriteTagList: Codable {
        let id, tagContent, tagUsageCnt: String
        let previewCards: [PreviewCard]
        let links: FavoriteTagListLinks

        enum CodingKeys: String, CodingKey {
            case id, tagContent, tagUsageCnt, previewCards
            case links = "_links"
        }
    }

    // MARK: - FavoriteTagListLinks
    struct FavoriteTagListLinks: Codable {
        let tagFeed: TagFeed

        enum CodingKeys: String, CodingKey {
            case tagFeed = "tag-feed"
        }
    }

    // MARK: - TagFeed
    struct TagFeed: Codable {
        let href: String
    }

    // MARK: - PreviewCard
    struct PreviewCard: Codable {
        let id, content: String
        let backgroundImgURL: TagFeed
        let links: PreviewCardLinks

        enum CodingKeys: String, CodingKey {
            case id, content
            case backgroundImgURL = "backgroundImgUrl"
            case links = "_links"
        }
    }

    // MARK: - PreviewCardLinks
    struct PreviewCardLinks: Codable {
        let detail: TagFeed
    }

    // MARK: - Status
    struct Status: Codable {
        let httpCode: Int
        let httpStatus, responseMessage: String
    }
    
    let embedded: Embedded
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case status
    }
}

