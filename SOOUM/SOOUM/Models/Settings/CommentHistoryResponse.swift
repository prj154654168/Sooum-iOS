//
//  CommentHistoryResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import Foundation

import Alamofire


struct CommentHistoryResponse: Codable {
    let embedded: CommentHistoryEmbedded
    let links: Next
    let status: Status
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
}

extension CommentHistoryResponse {
    
    init() {
        self.embedded = .init()
        self.links = .init()
        self.status = .init()
    }
}

extension CommentHistoryResponse: EmptyResponse {
    static func emptyValue() -> CommentHistoryResponse {
        CommentHistoryResponse.init()
    }
}

struct CommentHistoryEmbedded: Codable {
    let commentHistories: [CommentHistory]
    
    enum CodingKeys: String, CodingKey {
        case commentHistories = "myCommentCardDtoList"
    }
}

extension CommentHistoryEmbedded {
    
    init() {
        self.commentHistories = []
    }
}

struct CommentHistory: Equatable, Codable {
    let id: String
    let content: String
    let backgroundImgURL: URLString
    let font: Font
    let fontSize: FontSize
    let links: Detail
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case backgroundImgURL = "backgroundImgUrl"
        case font
        case fontSize
        case links = "_links"
    }
}

extension CommentHistory {
    
    init() {
        self.id = ""
        self.content = ""
        self.backgroundImgURL = .init()
        self.font = .pretendard
        self.fontSize = .none
        self.links = .init()
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.content = try container.decode(String.self, forKey: .content)
        self.backgroundImgURL = try container.decode(URLString.self, forKey: .backgroundImgURL)
        self.font = try container.decode(Font.self, forKey: .font)
        self.fontSize = try container.decode(FontSize.self, forKey: .fontSize)
        self.links = try container.decode(Detail.self, forKey: .links)
    }
}

extension CommentHistory {
    static func == (lhs: CommentHistory, rhs: CommentHistory) -> Bool {
        lhs.id == rhs.id
    }
}
