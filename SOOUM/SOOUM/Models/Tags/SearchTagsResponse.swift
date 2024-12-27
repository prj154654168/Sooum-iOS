//
//  SearchTagsResponse.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import Foundation

import Alamofire


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

extension SearchTagsResponse {
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.embedded = try container.decodeIfPresent(Embedded.self, forKey: .embedded) ?? .init(relatedTagList: [])
        self.status = try container.decode(Status.self, forKey: .status)
    }
}

extension SearchTagsResponse: EmptyResponse {
    static func emptyValue() -> SearchTagsResponse {
        SearchTagsResponse.init(
            embedded: .init(relatedTagList: []),
            status: .init(httpCode: 0, httpStatus: "", responseMessage: "")
        )
    }
}
