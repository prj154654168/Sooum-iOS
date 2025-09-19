//
//  CheckAvailableResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct CheckAvailableResponse {
    
    let checkAvailable: CheckAvailable
}

extension CheckAvailableResponse: EmptyResponse {
    
    static func emptyValue() -> CheckAvailableResponse {
        CheckAvailableResponse(checkAvailable: CheckAvailable.defaultValue)
    }
}

extension CheckAvailableResponse: Decodable {
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.checkAvailable = try singleContainer.decode(CheckAvailable.self)
    }
}
