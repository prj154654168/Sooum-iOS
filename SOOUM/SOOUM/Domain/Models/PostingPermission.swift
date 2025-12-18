//
//  PostingPermission.swift
//  SOOUM
//
//  Created by 오현식 on 10/30/25.
//

import Foundation

struct PostingPermission: Equatable {
    
    let isBaned: Bool
    let expiredAt: Date?
}

extension PostingPermission {
    
    static var defaultValue: PostingPermission = PostingPermission(
        isBaned: false,
        expiredAt: nil
    )
}

extension PostingPermission: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case isBaned
        case expiredAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isBaned = try container.decode(Bool.self, forKey: .isBaned)
        self.expiredAt = try container.decodeIfPresent(Date.self, forKey: .expiredAt)
    }
}
