//
//  FavoriteTagInfo.swift
//  SOOUM
//
//  Created by 오현식 on 11/18/25.
//

import Foundation

struct FavoriteTagInfo: Equatable {
    
    let id: String
    let title: String
}

extension FavoriteTagInfo {
    
    static var defaultValue: FavoriteTagInfo = FavoriteTagInfo(id: "", title: "")
}

extension FavoriteTagInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = String(try container.decode(Int64.self, forKey: .id))
        self.title = try container.decode(String.self, forKey: .title)
    }
}
