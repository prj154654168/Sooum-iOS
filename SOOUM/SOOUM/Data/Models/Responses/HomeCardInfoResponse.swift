//
//  HomeCardInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/28/25.
//

import Alamofire

struct HomeCardInfoResponse {
    
    let cardInfos: [BaseCardInfo]
}

extension HomeCardInfoResponse: EmptyResponse {
    
    static func emptyValue() -> HomeCardInfoResponse {
        HomeCardInfoResponse(cardInfos: [])
    }
}

extension HomeCardInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case cardInfos
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.cardInfos = try singleContainer.decode([BaseCardInfo].self)
    }
}
