//
//  ArticleCardInfo.swift
//  SOOUM
//
//  Created by 오현식 on 1/31/26.
//

import Foundation

/// 기본 모델이 A 유형
struct ArticleCardInfo: Hashable {
    let id: String
    let profileImageUrl: String
    let nickname: String
    let cardContent: String
    let isRead: Bool
    let writerProfileImgUrls: [String]
    let totalWriterCnt: Int
}

extension ArticleCardInfo {
    
    static var defaultValue: ArticleCardInfo = ArticleCardInfo(
        id: "",
        profileImageUrl: "",
        nickname: "",
        cardContent: "",
        isRead: false,
        writerProfileImgUrls: [],
        totalWriterCnt: 0
    )
}

extension ArticleCardInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id = "cardId"
        case profileImageUrl = "profileImgUrl"
        case nickname
        case cardContent
        case isRead
        case writerProfileImgUrls
        case totalWriterCnt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = String(try container.decode(Int64.self, forKey: .id))
        self.profileImageUrl = try container.decode(String.self, forKey: .profileImageUrl)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.cardContent = try container.decode(String.self, forKey: .cardContent)
        self.isRead = try container.decode(Bool.self, forKey: .isRead)
        self.writerProfileImgUrls = try container.decode([String].self, forKey: .writerProfileImgUrls)
        self.totalWriterCnt = try container.decode(Int.self, forKey: .totalWriterCnt)
    }
}
