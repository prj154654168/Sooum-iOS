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
}

extension DetailCardResponse {
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.detailCard = try singleContainer.decode(DetailCard.self)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Status.self, forKey: .status)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(self.detailCard)
        try container.encode(self.status)
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
