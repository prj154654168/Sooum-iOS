//
//  SignUpResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct SignUpResponse: Decodable {
    
    let accessToken: String
    let refreshToken: String
    let nickname: String
}

extension SignUpResponse: EmptyResponse {
    
    static func emptyValue() -> SignUpResponse {
        SignUpResponse(accessToken: "", refreshToken: "", nickname: "")
    }
}
