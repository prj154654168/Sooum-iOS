//
//  TagInfo.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

struct TagInfo {
    let id: String
    let name: String
    let usageCnt: Int
}

extension TagInfo {
    
    static var defaultValue: TagInfo = TagInfo(id: "", name: "", usageCnt: 0)
}

extension TagInfo: Hashable {
    
    static func == (lhs: TagInfo, rhs: TagInfo) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}

extension TagInfo: Decodable {
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case usageCnt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = String(try container.decode(Int64.self, forKey: .id))
        self.name = try container.decode(String.self, forKey: .name)
        self.usageCnt = try container.decode(Int.self, forKey: .usageCnt)
    }
}
