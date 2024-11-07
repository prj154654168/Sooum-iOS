//
//  DetailCommentCardResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/10/24.
//

import Foundation

import Alamofire

struct DetailCommentCardResponse: Codable {
    let detailCard: DetailCard
    let previousCardId: String
    let previousCardImgLink: URLString
    let status: Status
    
    enum CodingKeys: String, CodingKey {
        case detailCommentCard
        case previousCardId
        case previousCardImgLink
        case status
    }
}

extension DetailCommentCardResponse {
    
    init() {
        self.detailCard = .init()
        self.previousCardId = ""
        self.previousCardImgLink = .init()
        self.status = .init()
    }
    
    init(from decoder: any Decoder) throws {
        let SingleContainer = try decoder.singleValueContainer()
        self.detailCard = try SingleContainer.decode(DetailCard.self)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.previousCardId = try container.decode(String.self, forKey: .previousCardId)
        self.previousCardImgLink = try container.decode(URLString.self, forKey: .previousCardImgLink)
        self.status = try container.decode(Status.self, forKey: .status)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(self.detailCard)
        try container.encode(self.previousCardId)
        try container.encode(self.previousCardImgLink)
        try container.encode(self.status)
    }
}

extension DetailCommentCardResponse: EmptyResponse {
    static func emptyValue() -> DetailCommentCardResponse {
        DetailCommentCardResponse.init()
    }
}
