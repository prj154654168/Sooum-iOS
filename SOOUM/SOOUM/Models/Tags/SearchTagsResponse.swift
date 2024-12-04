//
//  SearchTagsResponse.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import Foundation

// MARK: - SearchTagsResponse
struct SearchTagsResponse: Codable {
    
    // MARK: - Embedded
    struct Embedded: Codable {
        let relatedTagList: [RelatedTag]
    }

    // MARK: - RelatedTagList
    struct RelatedTag: Codable {
        let tagId: String
        let count: Int
        let content: String
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


