//
//  SignUpResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct SignUpResponse {
    
    let token: Token
}

extension SignUpResponse: EmptyResponse {
    
    static func emptyValue() -> SignUpResponse {
        SignUpResponse(token: Token.defaultValue)
    }
}

extension SignUpResponse: Decodable {
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.token = try singleContainer.decode(Token.self)
    }
}
