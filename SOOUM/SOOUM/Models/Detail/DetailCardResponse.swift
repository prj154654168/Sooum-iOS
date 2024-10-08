//
//  DetailCardResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/24.
//

import Foundation


struct DetailCardResponse: Codable {
    let detailCard: DetailCard
    let status: Status
    
    enum CodingKeys: String, CodingKey {
        case detailCard
        case status
    }
    
    init(from decoder: any Decoder) throws {
        let SingleContainer = try decoder.singleValueContainer()
        self.detailCard = try SingleContainer.decode(DetailCard.self)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Status.self, forKey: .status)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(detailCard)
        try container.encode(status)
    }
    
    init() {
        self.detailCard = .init()
        self.status = .init()
    }
}

extension DetailCardResponse: EmptyInitializable {
    static func empty() -> DetailCardResponse {
        return .init()
    }
}

struct DetailCard: CardProtocol {
    
    let id: String
    let content: String
    
    let distance: Double?
    
    let createdAt: Date
    let storyExpirationTime: Date?
    
    let backgroundImgURL: Next
    
    let font: Font
    
    let isStory: Bool
    
    let isOwnCard: Bool
    
    let member: Member
    let tags: [Tag]

    enum CodingKeys: String, CodingKey {
        case id
        case distance
        case createdAt
        case storyExpirationTime
        case content
        case backgroundImgURL = "backgroundImgUrl"
        case font
        case isStory
        case isOwnCard
        case member
        case tags
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

extension DetailCard {
    init() {
        self.id = ""
        self.content = ""
        self.distance = nil
        self.createdAt = Date()
        self.storyExpirationTime = nil
        self.backgroundImgURL = .init(url: "")
        self.font = .pretendard
        self.isStory = false
        self.isOwnCard = false
        self.member = .init()
        self.tags = []
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
        self.backgroundImgURL = try container.decode(Next.self, forKey: .backgroundImgURL)
        self.font = try container.decode(Font.self, forKey: .font)
        self.isStory = try container.decode(Bool.self, forKey: .isStory)
        
        self.isOwnCard = try container.decode(Bool.self, forKey: .isOwnCard)
        self.member = try container.decode(Member.self, forKey: .member)
        self.tags = try container.decodeIfPresent([Tag].self, forKey: .tags) ?? []
    }
}

struct Member: Codable {
    let id: String
    let nickname: String
    let profileImgUrl: String?
    
    init() {
        self.id = ""
        self.nickname = ""
        self.profileImgUrl = nil
    }
}

struct Tag: Codable {
    let id: String
    let content: String
    let links: TagURL
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case links = "_links"
    }
}

struct TagURL: Codable {
    let tagFeed: Next
     
    enum CodingKeys: String, CodingKey {
        case tagFeed = "tag-feed"
    }
}
