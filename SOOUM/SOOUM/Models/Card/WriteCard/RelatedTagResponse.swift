//
//  RelatedTagResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/22/24.
//

import Foundation

import Alamofire


struct RelatedTagResponse: Codable {
    let embedded: RelatedTagEmbedded
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case status
    }
}

struct RelatedTagEmbedded: Equatable, Codable {
    let relatedTags: [RelatedTag]
    
    enum CodingKeys: String, CodingKey {
        case relatedTags = "relatedTagList"
    }
}

struct RelatedTag: Equatable, Codable {
    let count: Int
    let content: String
}

extension RelatedTagResponse {
    
    init() {
        self.embedded = .init(relatedTags: [])
        self.status = .init()
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.embedded = try container.decodeIfPresent(RelatedTagEmbedded.self, forKey: .embedded) ?? .init(relatedTags: [])
        self.status = try container.decode(Status.self, forKey: .status)
    }
}

extension RelatedTagResponse: EmptyResponse {
    static func emptyValue() -> RelatedTagResponse {
        RelatedTagResponse.init()
    }
}
