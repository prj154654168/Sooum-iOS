//
//  SignUpResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

import Alamofire


struct SignUpResponse: Codable {
    let status: Status
    let token: Token
    let links: Links

    enum CodingKeys: String, CodingKey {
        case status
        case token
        case links = "_links"
    }
}

extension SignUpResponse {
    
    init() {
        self.status = .init()
        self.token = .init(accessToken: "", refreshToken: "")
        self.links = .init(login: nil, home: nil)
    }
}

extension SignUpResponse: EmptyResponse {
    static func emptyValue() -> SignUpResponse {
        SignUpResponse.init()
    }
}
