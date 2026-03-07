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
    let abTestType: TestType
    let profileImageUrl: String
    let nickname: String
    let cardContent: String
    let isRead: Bool
    let articleTypeB: ArticleTypeB?
}

extension ArticleCardInfo {
    /// 테스트 구분 유형
    enum TestType: String, Decodable {
        case a = "A"
        case b = "B"
        case none = "NONE"
    }
}

extension ArticleCardInfo {
    /// 유형 B
    struct ArticleTypeB: Hashable {
        let writerProfileImgUrls: [String]
        let totalWriterCnt: Int
    }
}

extension ArticleCardInfo.ArticleTypeB: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case writerProfileImgUrls
        case totalWriterCnt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.writerProfileImgUrls = try container.decode([String].self, forKey: .writerProfileImgUrls)
        self.totalWriterCnt = try container.decode(Int.self, forKey: .totalWriterCnt)
    }
}

extension ArticleCardInfo {
    
    static var defaultValue: ArticleCardInfo = ArticleCardInfo(
        id: "",
        abTestType: .none,
        profileImageUrl: "",
        nickname: "",
        cardContent: "",
        isRead: false,
        articleTypeB: nil
    )
}

extension ArticleCardInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id = "cardId"
        case abTestType
        case profileImageUrl = "profileImgUrl"
        case nickname
        case cardContent
        case isRead
        case articleTypeB
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = String(try container.decode(Int64.self, forKey: .id))
        self.abTestType = try container.decode(TestType.self, forKey: .abTestType)
        self.profileImageUrl = try container.decode(String.self, forKey: .profileImageUrl)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.cardContent = try container.decode(String.self, forKey: .cardContent)
        self.isRead = try container.decode(Bool.self, forKey: .isRead)
        
        let singleContainer = try decoder.singleValueContainer()
        self.articleTypeB = try? singleContainer.decode(ArticleTypeB.self)
    }
}
