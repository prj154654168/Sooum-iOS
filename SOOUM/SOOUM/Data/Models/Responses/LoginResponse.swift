//
//  LoginResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct LoginResponse: Decodable {
    
    let accessToken: String
    let refreshToken: String
}

extension LoginResponse: EmptyResponse {
    
    static func emptyValue() -> LoginResponse {
        LoginResponse(accessToken: "", refreshToken: "")
    }
}
