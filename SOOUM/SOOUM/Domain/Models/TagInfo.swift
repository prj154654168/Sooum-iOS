//
//  TagInfo.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

struct TagInfo: Equatable {
    let id: String
    let name: String
    let usageCnt: Int
}

extension TagInfo {
    
    static var defaultValue: TagInfo = TagInfo(id: "", name: "", usageCnt: 0)
}

extension TagInfo: Decodable { }
