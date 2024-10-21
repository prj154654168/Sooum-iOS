//
//  DetailCardByCommentResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/15/24.
//

import Foundation


struct DetailCardByCommentResponse: Codable {
    let detailCard: DetailCard
    let prevCard: PrevCard
    let status: Status
    
    enum CodingKeys: String, CodingKey {
        case detailCard
        case prevCard
        case status
    }
}

extension DetailCardByCommentResponse {
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.detailCard = try singleContainer.decode(DetailCard.self)
        self.prevCard = try singleContainer.decode(PrevCard.self)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Status.self, forKey: .status)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(self.detailCard)
        try container.encode(self.prevCard)
        try container.encode(self.status)
    }
    
    init() {
        self.detailCard = .init()
        self.prevCard = .init()
        self.status = .init()
    }
}

extension DetailCardByCommentResponse: EmptyInitializable {
    static func empty() -> DetailCardByCommentResponse {
        return .init()
    }
}

struct PrevCard: Equatable, Codable {
    let previousCardId: String
    let previousCardImgLink: URLString
}

extension PrevCard {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.previousCardId == rhs.previousCardId
    }
}

extension PrevCard {
    
    init() {
        self.previousCardId = ""
        self.previousCardImgLink = .init()
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.previousCardId = try container.decode(String.self, forKey: .previousCardId)
        self.previousCardImgLink = try container.decode(URLString.self, forKey: .previousCardImgLink)
    }
}
