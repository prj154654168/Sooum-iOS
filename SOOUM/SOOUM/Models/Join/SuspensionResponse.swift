//
//  SuspensionResponse.swift
//  SOOUM
//
//  Created by 오현식 on 1/17/25.
//

import Foundation

import Alamofire


struct SuspensionResponse: Codable {
    
    let suspension: Suspension?
    let status: Status?
}

extension SuspensionResponse {
    
    init() {
        self.suspension = nil
        self.status = nil
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Status.self, forKey: .status)
        
        let singleContainer = try decoder.singleValueContainer()
        self.suspension = try singleContainer.decode(Suspension.self)
    }
}

extension SuspensionResponse: EmptyResponse {
    
    static func emptyValue() -> SuspensionResponse {
        SuspensionResponse()
    }
}

struct Suspension: Codable, Equatable {
    
    let untilBan: Date
    let isBanUser: Bool
}

extension Suspension {
    
    init() {
        self.untilBan = Date()
        self.isBanUser = false
    }
}
