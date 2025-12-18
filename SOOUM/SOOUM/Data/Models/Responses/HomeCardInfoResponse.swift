//
//  BaseCardInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/28/25.
//

import Alamofire

struct BaseCardInfoResponse {
    
    let cardInfos: [BaseCardInfo]
}

extension BaseCardInfoResponse: EmptyResponse {
    
    static func emptyValue() -> BaseCardInfoResponse {
        BaseCardInfoResponse(cardInfos: [])
    }
}

extension BaseCardInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case cardInfos
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.cardInfos = try singleContainer.decode([BaseCardInfo].self)
    }
}
