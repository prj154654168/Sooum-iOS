//
//  FollowInfo.swift
//  SOOUM
//
//  Created by 오현식 on 11/6/25.
//

import Foundation

struct FollowInfo: Hashable {
    
    let memberId: String
    let nickname: String
    let profileImageUrl: String?
    let isFollowing: Bool
    let isRequester: Bool
}

extension FollowInfo {
    
    static var defaultValue: FollowInfo = FollowInfo(
        memberId: "",
        nickname: "",
        profileImageUrl: nil,
        isFollowing: false,
        isRequester: false
    )
}

extension FollowInfo: Decodable {
    
    enum CodingKeys: CodingKey {
        case memberId
        case nickname
        case profileImageUrl
        case isFollowing
        case isRequester
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.memberId = String(try container.decode(Int64.self, forKey: .memberId))
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        self.isFollowing = try container.decode(Bool.self, forKey: .isFollowing)
        self.isRequester = try container.decode(Bool.self, forKey: .isRequester)
    }
}
