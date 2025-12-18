//
//  TokenResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Alamofire

struct TokenResponse {
    
    let token: Token
}

extension TokenResponse: EmptyResponse {
    
    static func emptyValue() -> TokenResponse {
        TokenResponse(token: Token.defaultValue)
    }
}

extension TokenResponse: Decodable {
    
    enum CodingKeys: CodingKey {
        case token
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.token = try singleContainer.decode(Token.self)
    }
}
