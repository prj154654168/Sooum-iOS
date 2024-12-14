//
//  FollowingResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import Foundation

import Alamofire


struct FollowingResponse: Codable {
    let embedded: FollowingEmbedded
    let links: Next
    let status: Status
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
}

extension FollowingResponse {
    
    init() {
        self.embedded = .init()
        self.links = .init()
        self.status = .init()
    }
}

extension FollowingResponse: EmptyResponse {
    static func emptyValue() -> FollowingResponse {
        FollowingResponse.init()
    }
}

struct FollowingEmbedded: Codable {
    let followings: [Follow]
    
    enum CodingKeys: String, CodingKey {
        case followings = "followingInfoList"
    }
}

extension FollowingEmbedded {
    
    init() {
        self.followings = []
    }
}

struct Follow: Equatable, Codable {
    let id: String
    let nickname: String
    let backgroundImgURL: URLString?
    let links: ProfileLinks
    let isFollowing: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case nickname
        case backgroundImgURL = "backgroundImgUrl"
        case links = "_links"
        case isFollowing
    }
}

extension Follow {
    
    init() {
        self.id = ""
        self.nickname = ""
        self.backgroundImgURL = nil
        self.links = .init()
        self.isFollowing = false
    }
}

extension Follow {
    static func == (lhs: Follow, rhs: Follow) -> Bool {
        lhs.id == rhs.id
    }
}

/// 상세보기 프로필 URL
struct ProfileLinks: Codable {
    let profile: URLString
}
extension ProfileLinks {
    init() {
        self.profile = .init()
    }
}
