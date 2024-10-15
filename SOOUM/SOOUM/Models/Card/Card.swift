//
//  Card.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/24.
//

import Foundation


struct Card: CardProtocol {
    let id: String
    let content: String
    
    let distance: Double?
    
    let createdAt: Date
    let storyExpirationTime: Date?
    
    let likeCnt: Int
    let commentCnt: Int
    
    let backgroundImgURL: URLString
    let links: Detail
    
    let font: Font
    let fontSize: FontSize
    
    let isLiked: Bool
    let isCommentWritten: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case distance
        case createdAt
        case storyExpirationTime
        case likeCnt
        case commentCnt
        case backgroundImgURL = "backgroundImgUrl"
        case links = "_links"
        case font
        case fontSize
        case isLiked
        case isCommentWritten
    }
}

extension Card {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Card {
    
    init() {
        self.id = ""
        self.content = ""
        self.distance = nil
        self.createdAt = Date()
        self.storyExpirationTime = nil
        self.likeCnt = 0
        self.commentCnt = 0
        self.backgroundImgURL = .init()
        self.links = .init()
        self.font = .pretendard
        self.fontSize = .big
        self.isLiked = false
        self.isCommentWritten = false
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.distance = try container.decodeIfPresent(Double.self, forKey: .distance)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.storyExpirationTime = try container.decodeIfPresent(
            Date.self,
            forKey: .storyExpirationTime
        )
        self.content = try container.decode(String.self, forKey: .content)
        self.likeCnt = try container.decode(Int.self, forKey: .likeCnt)
        self.commentCnt = try container.decode(Int.self, forKey: .commentCnt)
        self.backgroundImgURL = try container.decode(URLString.self, forKey: .backgroundImgURL)
        self.links = try container.decode(Detail.self, forKey: .links)
        self.font = try container.decode(Font.self, forKey: .font)
        self.fontSize = try container.decode(FontSize.self, forKey: .fontSize)
        self.isLiked = try container.decode(Bool.self, forKey: .isLiked)
        self.isCommentWritten = try container.decode(Bool.self, forKey: .isCommentWritten)
    }
}
