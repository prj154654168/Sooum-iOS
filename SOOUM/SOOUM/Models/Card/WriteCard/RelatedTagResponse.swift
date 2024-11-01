//
//  RelatedTagResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/22/24.
//

import Foundation


struct RelatedTagResponse: Codable {
    let embedded: RelatedTagEmbedded
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case status
    }
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

extension RelatedTagResponse: EmptyInitializable {
    static func empty() -> RelatedTagResponse {
        return .init(embedded: .init(relatedTags: []), status: .init())
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
