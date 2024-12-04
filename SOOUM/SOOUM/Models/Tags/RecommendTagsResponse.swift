//
//  RecommendTagsResponse.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import Foundation

struct RecommendTagsResponse: Codable {
    
    // MARK: - Embedded
    struct Embedded: Codable {
        let recommendTagList: [RecommendTag]
    }

    // MARK: - RecommendTag
    struct RecommendTag: Codable {
        let tagID, tagContent, tagUsageCnt: String
        let links: Links

        enum CodingKeys: String, CodingKey {
            case tagID = "tagId"
            case tagContent, tagUsageCnt
            case links = "_links"
        }
    }

    // MARK: - Links
    struct Links: Codable {
        let tagFeed: TagFeed

        enum CodingKeys: String, CodingKey {
            case tagFeed = "tag-feed"
        }
    }

    // MARK: - TagFeed
    struct TagFeed: Codable {
        let href: String
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
