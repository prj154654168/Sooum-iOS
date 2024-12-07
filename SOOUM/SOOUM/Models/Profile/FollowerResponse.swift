//
//  FollowerResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import Foundation

import Alamofire


struct FollowerResponse: Codable {
    let embedded: FollowerEmbedded
    let links: Next
    let status: Status
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
}

extension FollowerResponse {
    
    init() {
        self.embedded = .init()
        self.links = .init()
        self.status = .init()
    }
}

extension FollowerResponse: EmptyResponse {
    static func emptyValue() -> FollowerResponse {
        FollowerResponse.init()
    }
}

struct FollowerEmbedded: Codable {
    let followers: [Follow]
    
    enum CodingKeys: String, CodingKey {
        case followers = "followerInfoList"
    }
}

extension FollowerEmbedded {
    
    init() {
        self.followers = []
    }
}
