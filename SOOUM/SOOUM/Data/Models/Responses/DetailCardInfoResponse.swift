//
//  DetailCardInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import Alamofire

struct DetailCardInfoResponse {
    
    let cardInfos: DetailCardInfo
}

extension DetailCardInfoResponse: EmptyResponse {
    
    static func emptyValue() -> DetailCardInfoResponse {
        DetailCardInfoResponse(cardInfos: DetailCardInfo.defaultValue)
    }
}

extension DetailCardInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case cardInfos
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.cardInfos = try singleContainer.decode(DetailCardInfo.self)
    }
}
