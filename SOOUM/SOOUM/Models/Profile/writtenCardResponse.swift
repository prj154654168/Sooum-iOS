//
//  writtenCardResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import Foundation

import Alamofire


struct WrittenCardResponse: Codable {
    let embedded: WrittenCardEmbedded
    let status: Status
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case status
    }
}

extension WrittenCardResponse {
    
    init() {
        self.embedded = .init()
        self.status = .init()
    }
}

extension WrittenCardResponse: EmptyResponse {
    static func emptyValue() -> WrittenCardResponse {
        WrittenCardResponse.init()
    }
}

struct WrittenCardEmbedded: Codable {
    let writtenCards: [WrittenCard]
    
    enum CodingKeys: String, CodingKey {
        case writtenCards = "myFeedCardDtoList"
    }
}

extension WrittenCardEmbedded {
    
    init() {
        self.writtenCards = []
    }
}

struct WrittenCard: Equatable, Codable {
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

extension WrittenCard {
    
    init() {
        self.id = ""
        self.content = ""
        self.backgroundImgURL = .init()
        self.font = .pretendard
        self.fontSize = .none
        self.links = .init()
    }
}

extension WrittenCard {
    static func == (lhs: WrittenCard, rhs: WrittenCard) -> Bool {
        lhs.id == rhs.id
    }
}
