//
//  PushNotiStatusInfo.swift
//  SOOUM
//
//  Created by 오현식 on 3/8/26.
//

import Foundation

struct PushNotiStatusInfo: Equatable {
    let commentCardNotify: Bool
    let cardLikeNotify: Bool
    let followUserCardNotify: Bool
    let newFollowerNotify: Bool
    let cardNewCommentNotify: Bool
    let recommendedContentNotify: Bool
    let favoriteTagNotify: Bool
    let serviceUpdateNotify: Bool
    let policyViolationNotify: Bool
}

extension PushNotiStatusInfo {
    
    static var defaultValue: PushNotiStatusInfo = PushNotiStatusInfo(
        commentCardNotify: false,
        cardLikeNotify: false,
        followUserCardNotify: false,
        newFollowerNotify: false,
        cardNewCommentNotify: false,
        recommendedContentNotify: false,
        favoriteTagNotify: false,
        serviceUpdateNotify: false,
        policyViolationNotify: false
    )
}

extension PushNotiStatusInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case commentCardNotify
        case cardLikeNotify
        case followUserCardNotify
        case newFollowerNotify
        case cardNewCommentNotify
        case recommendedContentNotify
        case favoriteTagNotify
        case serviceUpdateNotify
        case policyViolationNotify
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentCardNotify = try container.decode(Bool.self, forKey: .commentCardNotify)
        self.cardLikeNotify = try container.decode(Bool.self, forKey: .cardLikeNotify)
        self.followUserCardNotify = try container.decode(Bool.self, forKey: .followUserCardNotify)
        self.newFollowerNotify = try container.decode(Bool.self, forKey: .newFollowerNotify)
        self.cardNewCommentNotify = try container.decode(Bool.self, forKey: .cardNewCommentNotify)
        self.recommendedContentNotify = try container.decode(Bool.self, forKey: .recommendedContentNotify)
        self.favoriteTagNotify = try container.decode(Bool.self, forKey: .favoriteTagNotify)
        self.serviceUpdateNotify = try container.decode(Bool.self, forKey: .serviceUpdateNotify)
        self.policyViolationNotify = try container.decode(Bool.self, forKey: .policyViolationNotify)
    }
}
