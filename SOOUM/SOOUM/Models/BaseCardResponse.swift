//
//  BaseResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import Foundation


struct Status: Codable {
    let httpCode: Int
    let httpStatus: String
    let responseMessage: String
}

struct Card: Equatable, Codable {
    let id: String
    let distance: Double?
    
    let createdAt: Date
    let storyExpirationTime: Date?
    
    let content: String
    
    let likeCnt: Int
    let commentCnt: Int
    
    let backgroundImgURL: Next
    let links: CardDetail
    
    let font: Font
    let fontSize: FontSize
    
    let isStory: Bool
    let isLiked: Bool
    let isCommentWritten: Bool
    
    enum Font: String, Codable {
        case pretendard = "PRETENDARD"
        case school = "SCHOOL_SAFE_CHALKBOARD_ERASER"
    }

    enum FontSize: String, Codable {
        case big = "BIG"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case distance
        case createdAt
        case storyExpirationTime
        case content
        case likeCnt
        case commentCnt
        case backgroundImgURL = "backgroundImgUrl"
        case links = "_links"
        case font
        case fontSize
        case isStory
        case isLiked
        case isCommentWritten
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    
    init() {
        self.id = ""
        self.distance = nil
        self.createdAt = Date()
        self.storyExpirationTime = nil
        self.content = ""
        self.likeCnt = 0
        self.commentCnt = 0
        self.backgroundImgURL = .init(url: "")
        self.links = .init(detail: .init(url: ""))
        self.font = .pretendard
        self.fontSize = .big
        self.isStory = false
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
        self.backgroundImgURL = try container.decode(Next.self, forKey: .backgroundImgURL)
        self.links = try container.decode(CardDetail.self, forKey: .links)
        self.font = try container.decode(Self.Font.self, forKey: .font)
        self.fontSize = try container.decode(Self.FontSize.self, forKey: .fontSize)
        self.isStory = try container.decode(Bool.self, forKey: .isStory)
        self.isLiked = try container.decode(Bool.self, forKey: .isLiked)
        self.isCommentWritten = try container.decode(Bool.self, forKey: .isCommentWritten)
    }
}

struct CardURL: Codable {
    let next: Next
}

struct Next: Codable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url = "href"
    }
}

struct CardDetail: Codable {
    let detail: Next
}
