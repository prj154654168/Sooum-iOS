//
//  DetailCardInfo.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import Foundation

struct DetailCardInfo: Hashable {
    let id: String
    let likeCnt: Int
    let commentCnt: Int
    let cardImgName: String
    let cardImgURL: String
    let cardContent: String
    let font: BaseCardInfo.Font
    let distance: String?
    let createdAt: Date
    let storyExpirationTime: Date?
    let isAdminCard: Bool
    let memberId: String
    let nickname: String
    let profileImgURL: String?
    let isLike: Bool
    let isCommentWritten: Bool
    let tags: [Tag]
    let isOwnCard: Bool
    let visitedCnt: String
    /// 이전 카드 정보
    let prevCardInfo: PrevCardInfo?
}

extension DetailCardInfo {
    
    func updateLikeCnt(_ likeCnt: Int, with isLike: Bool) -> DetailCardInfo {
        
        return DetailCardInfo(
            id: self.id,
            likeCnt: likeCnt,
            commentCnt: self.commentCnt,
            cardImgName: self.cardImgName,
            cardImgURL: self.cardImgURL,
            cardContent: self.cardContent,
            font: self.font,
            distance: self.distance,
            createdAt: self.createdAt,
            storyExpirationTime: self.storyExpirationTime,
            isAdminCard: self.isAdminCard,
            memberId: self.memberId,
            nickname: self.nickname,
            profileImgURL: self.profileImgURL,
            isLike: isLike,
            isCommentWritten: self.isCommentWritten,
            tags: self.tags,
            isOwnCard: self.isOwnCard,
            visitedCnt: self.visitedCnt,
            prevCardInfo: self.prevCardInfo
        )
    }
}

extension DetailCardInfo {
    /// 작성된 태그
    struct Tag: Hashable {
        let id: String
        let title: String
    }
    /// 이전 카드 정보
    struct PrevCardInfo: Hashable {
        let prevCardId: String
        let isPrevCardDeleted: Bool
        let prevCardImgURL: String?
    }
}

extension DetailCardInfo.Tag: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id = "tagId"
        case title = "name"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = String(try container.decode(Int64.self, forKey: .id))
        self.title = try container.decode(String.self, forKey: .title)
    }
}

extension DetailCardInfo.PrevCardInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case prevCardId = "previousCardId"
        case isPrevCardDeleted = "isPreviousCardDeleted"
        case prevCardImgURL = "previousCardImgUrl"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.prevCardId = try container.decode(String.self, forKey: .prevCardId)
        self.isPrevCardDeleted = try container.decode(Bool.self, forKey: .isPrevCardDeleted)
        self.prevCardImgURL = try container.decodeIfPresent(String.self, forKey: .prevCardImgURL)
    }
}

extension DetailCardInfo {
    
    static var defaultValue: DetailCardInfo = DetailCardInfo(
        id: "",
        likeCnt: 0,
        commentCnt: 0,
        cardImgName: "",
        cardImgURL: "",
        cardContent: "",
        font: .pretendard,
        distance: nil,
        createdAt: Date(),
        storyExpirationTime: nil,
        isAdminCard: false,
        memberId: "",
        nickname: "",
        profileImgURL: nil,
        isLike: false,
        isCommentWritten: false,
        tags: [],
        isOwnCard: false,
        visitedCnt: "0",
        prevCardInfo: nil
    )
}

extension DetailCardInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id = "cardId"
        case likeCnt
        case commentCnt = "commentCardCnt"
        case cardImgName
        case cardImgURL = "cardImgUrl"
        case cardContent
        case font
        case distance
        case createdAt
        case storyExpirationTime
        case isAdminCard
        case memberId
        case nickname
        case profileImgURL = "profileImgUrl"
        case isLike
        case isCommentWritten
        case tags
        case isOwnCard
        case visitedCnt
        case prevCardInfo
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = String(try container.decode(Int64.self, forKey: .id))
        self.likeCnt = try container.decode(Int.self, forKey: .likeCnt)
        self.commentCnt = try container.decode(Int.self, forKey: .commentCnt)
        self.cardImgName = try container.decode(String.self, forKey: .cardImgName)
        self.cardImgURL = try container.decode(String.self, forKey: .cardImgURL)
        self.cardContent = try container.decode(String.self, forKey: .cardContent)
        self.font = try container.decode(BaseCardInfo.Font.self, forKey: .font)
        self.distance = try container.decodeIfPresent(String.self, forKey: .distance)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.storyExpirationTime = try container.decodeIfPresent(Date.self, forKey: .storyExpirationTime)
        self.isAdminCard = try container.decode(Bool.self, forKey: .isAdminCard)
        self.memberId = String(try container.decode(Int64.self, forKey: .memberId))
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.profileImgURL = try container.decodeIfPresent(String.self, forKey: .profileImgURL)
        self.isLike = try container.decode(Bool.self, forKey: .isLike)
        self.isCommentWritten = try container.decode(Bool.self, forKey: .isCommentWritten)
        self.tags = try container.decode([Tag].self, forKey: .tags)
        self.isOwnCard = try container.decode(Bool.self, forKey: .isOwnCard)
        self.visitedCnt = String(try container.decode(Int64.self, forKey: .visitedCnt))
        
        let singleContainer = try decoder.singleValueContainer()
        self.prevCardInfo = try? singleContainer.decode(PrevCardInfo.self)
    }
}
