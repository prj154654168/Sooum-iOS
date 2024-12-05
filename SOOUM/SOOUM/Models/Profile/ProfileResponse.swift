//
//  ProfileResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import Foundation

import Alamofire


struct ProfileResponse: Codable {
    let profile: Profile
    let status: Status
    
    enum CodingKeys: String, CodingKey {
        case profile
        case status
    }
}

extension ProfileResponse {
    
    init() {
        self.profile = .init()
        self.status = .init()
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Status.self, forKey: .status)
        
        let singleContainer = try decoder.singleValueContainer()
        self.profile = try singleContainer.decode(Profile.self)
    }
}

extension ProfileResponse: EmptyResponse {
    static func emptyValue() -> ProfileResponse {
        ProfileResponse.init()
    }
}

struct Profile: Equatable, Codable {
    let nickname: String
    let currentDayVisitors: String
    let totalVisitorCnt: String
    let profileImg: URLString?
    let cardCnt: String
    let followingCnt: String
    let followerCnt: String
    let following: Bool?
    let isFollowing: Bool?
}

extension Profile {
    
    init() {
        self.nickname = ""
        self.currentDayVisitors = "0"
        self.totalVisitorCnt = "0"
        self.profileImg = nil
        self.cardCnt = "0"
        self.followingCnt = "0"
        self.followerCnt = "0"
        self.following = nil
        self.isFollowing = nil
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.currentDayVisitors = try container.decode(String.self, forKey: .currentDayVisitors)
        self.totalVisitorCnt = try container.decode(String.self, forKey: .totalVisitorCnt)
        self.profileImg = try container.decodeIfPresent(URLString.self, forKey: .profileImg)
        self.cardCnt = try container.decode(String.self, forKey: .cardCnt)
        self.followingCnt = try container.decode(String.self, forKey: .followingCnt)
        self.followerCnt = try container.decode(String.self, forKey: .followerCnt)
        self.following = try container.decodeIfPresent(Bool.self, forKey: .following)
        self.isFollowing = try container.decodeIfPresent(Bool.self, forKey: .isFollowing)
    }
}
