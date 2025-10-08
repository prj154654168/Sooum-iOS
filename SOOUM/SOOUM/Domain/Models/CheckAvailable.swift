//
//  CheckAvailable.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation

struct CheckAvailable: Equatable {
    
    let rejoinAvailableAt: Date?
    let banned: Bool
    let withdrawn: Bool
    let registered: Bool
}

extension CheckAvailable {
    
    static var defaultValue: CheckAvailable = CheckAvailable(
        rejoinAvailableAt: nil,
        banned: false,
        withdrawn: false,
        registered: false
    )
}

extension CheckAvailable: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case rejoinAvailableAt
        case banned
        case withdrawn
        case registered
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rejoinAvailableAt = try container.decodeIfPresent(Date.self, forKey: .rejoinAvailableAt)
        self.banned = try container.decode(Bool.self, forKey: .banned)
        self.withdrawn = try container.decode(Bool.self, forKey: .withdrawn)
        self.registered = try container.decode(Bool.self, forKey: .registered)
    }
}
