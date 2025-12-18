//
//  ProfileInfo.swift
//  SOOUM
//
//  Created by 오현식 on 11/6/25.
//

import Foundation

struct ProfileInfo: Hashable {
    
    let userId: String
    let nickname: String
    let profileImgName: String?
    let profileImageUrl: String?
    let totalVisitCnt: String
    let todayVisitCnt: String
    let cardCnt: String
    let followingCnt: String
    let followerCnt: String
    // 상대방 프로필 조회
    let isAlreadyFollowing: Bool?
    let isBlocked: Bool?
}

extension ProfileInfo {
    
    enum Content: String {
        case card       = "카드"
        case follower   = "팔로워"
        case following  = "팔로잉"
    }
}

extension ProfileInfo {
    
    static var defaultValue: ProfileInfo = ProfileInfo(
        userId: "",
        nickname: "",
        profileImgName: nil,
        profileImageUrl: nil,
        totalVisitCnt: "",
        todayVisitCnt: "",
        cardCnt: "0",
        followingCnt: "0",
        followerCnt: "0",
        isAlreadyFollowing: nil,
        isBlocked: nil
    )
}

extension ProfileInfo: Decodable {
    
    enum CodingKeys: CodingKey {
        case userId
        case nickname
        case profileImgName
        case profileImageUrl
        case totalVisitCnt
        case todayVisitCnt
        case cardCnt
        case followingCnt
        case followerCnt
        case isAlreadyFollowing
        case isBlocked
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = String(try container.decode(Int64.self, forKey: .userId))
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.profileImgName = try container.decodeIfPresent(String.self, forKey: .profileImgName)
        self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        self.totalVisitCnt = String(try container.decode(Int64.self, forKey: .totalVisitCnt))
        self.todayVisitCnt = String(try container.decode(Int64.self, forKey: .todayVisitCnt))
        self.cardCnt = String(try container.decode(Int64.self, forKey: .cardCnt))
        self.followingCnt = String(try container.decode(Int64.self, forKey: .followingCnt))
        self.followerCnt = String(try container.decode(Int64.self, forKey: .followerCnt))
        self.isAlreadyFollowing = try container.decodeIfPresent(Bool.self, forKey: .isAlreadyFollowing)
        self.isBlocked = try container.decodeIfPresent(Bool.self, forKey: .isBlocked)
    }
}
