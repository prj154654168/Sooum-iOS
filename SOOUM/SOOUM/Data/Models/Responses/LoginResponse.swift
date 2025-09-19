//
//  LoginResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct LoginResponse {
    
    let token: Token
}

extension LoginResponse: EmptyResponse {
    
    static func emptyValue() -> LoginResponse {
        LoginResponse(token: Token.defaultValue)
    }
}

extension LoginResponse: Decodable {
    
    enum CodingKeys: CodingKey {
        case token
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.token = try singleContainer.decode(Token.self)
    }
}
