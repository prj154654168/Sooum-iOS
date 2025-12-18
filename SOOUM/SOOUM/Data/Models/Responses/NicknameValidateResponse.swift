//
//  NicknameValidateResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct NicknameValidateResponse: Decodable {
    
    let isAvailable: Bool
}

extension NicknameValidateResponse: EmptyResponse {
    
    static func emptyValue() -> NicknameValidateResponse {
        NicknameValidateResponse(isAvailable: false)
    }
}
