//
//  BlockUserInfo.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Foundation

struct BlockUserInfo: Hashable {
    
    let id: String
    let userId: String
    let nickname: String
    let profileImageUrl: String?
}

extension BlockUserInfo {
    
    static var defaultValue: BlockUserInfo = BlockUserInfo(
        id: "",
        userId: "",
        nickname: "",
        profileImageUrl: nil
    )
}

extension BlockUserInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id = "blockId"
        case userId = "blockMemberId"
        case nickname = "blockMemberNickname"
        case profileImageUrl = "blockMemberProfileImageUrl"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = String(try container.decode(Int64.self, forKey: .id))
        self.userId = String(try container.decode(Int64.self, forKey: .userId))
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
    }
}
