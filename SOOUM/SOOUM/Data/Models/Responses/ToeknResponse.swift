//
//  TokenResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Alamofire

struct TokenResponse: Decodable {
    
    let token: Token
}

extension TokenResponse: EmptyResponse {
    
    static func emptyValue() -> TokenResponse {
        TokenResponse(token: Token.defaultValue)
    }
}
