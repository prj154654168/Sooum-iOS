//
//  RejoinableDateInfo.swift
//  SOOUM
//
//  Created by 오현식 on 11/13/25.
//

import Foundation

struct RejoinableDateInfo: Equatable {
    
    let rejoinableDate: Date
    let isActivityRestricted: Bool
}

extension RejoinableDateInfo {
    
    static var defaultValue: RejoinableDateInfo = RejoinableDateInfo(
        rejoinableDate: Date(),
        isActivityRestricted: false
    )
}

extension RejoinableDateInfo: Decodable {
    
    enum CodingKeys: CodingKey {
        case rejoinableDate
        case isActivityRestricted
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rejoinableDate = try container.decode(Date.self, forKey: .rejoinableDate)
        self.isActivityRestricted = try container.decode(Bool.self, forKey: .isActivityRestricted)
    }
}
