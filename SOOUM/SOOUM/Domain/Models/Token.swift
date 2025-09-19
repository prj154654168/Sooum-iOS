//
//  Token.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

struct Token: Decodable {
    
    var accessToken: String
    var refreshToken: String
}

extension Token {
    
    static var defaultValue: Token = Token(accessToken: "", refreshToken: "")
}
