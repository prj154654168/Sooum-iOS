//
//  BaseCardInfo.swift
//  SOOUM
//
//  Created by 오현식 on 9/28/25.
//

import Foundation

struct BaseCardInfo: Hashable {
    let id: String
    let likeCnt: Int
    let commentCnt: Int
    let cardImgName: String
    let cardImgURL: String
    let cardContent: String
    let font: Font
    let distance: String?
    let createdAt: Date
    let storyExpirationTime: Date?
    let isAdminCard: Bool
}

extension BaseCardInfo {
    
    func updateLikeCnt(_ likeCnt: Int) -> BaseCardInfo {
        
        return BaseCardInfo(
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
            isAdminCard: self.isAdminCard
        )
    }
    
    func updateCommentCnt(_ commentCnt: Int) -> BaseCardInfo {
        
        return BaseCardInfo(
            id: self.id,
            likeCnt: self.likeCnt,
            commentCnt: commentCnt,
            cardImgName: self.cardImgName,
            cardImgURL: self.cardImgURL,
            cardContent: self.cardContent,
            font: self.font,
            distance: self.distance,
            createdAt: self.createdAt,
            storyExpirationTime: self.storyExpirationTime,
            isAdminCard: self.isAdminCard
        )
    }
}

extension BaseCardInfo {
    /// 사용하는 폰트
    enum Font: String, Decodable {
        case pretendard = "PRETENDARD"
        case yoonwoo = "YOONWOO"
        case ridi = "RIDI"
        case kkookkkook = "KKOOKKKOOK"
    }
    /// 사용할 이미지 유형
    enum ImageType: String, Decodable {
        case `default` = "DEFAULT"
        case user = "USER"
    }
}

extension BaseCardInfo {
    
    static var defaultValue: BaseCardInfo = BaseCardInfo(
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
        isAdminCard: false
    )
}

extension BaseCardInfo: Decodable {
    
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
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = String(try container.decode(Int64.self, forKey: .id))
        self.likeCnt = try container.decode(Int.self, forKey: .likeCnt)
        self.commentCnt = try container.decode(Int.self, forKey: .commentCnt)
        self.cardImgName = try container.decode(String.self, forKey: .cardImgName)
        self.cardImgURL = try container.decode(String.self, forKey: .cardImgURL)
        self.cardContent = try container.decode(String.self, forKey: .cardContent)
        self.font = try container.decode(Font.self, forKey: .font)
        self.distance = try container.decodeIfPresent(String.self, forKey: .distance)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.storyExpirationTime = try container.decodeIfPresent(Date.self, forKey: .storyExpirationTime)
        self.isAdminCard = try container.decode(Bool.self, forKey: .isAdminCard)
    }
}
