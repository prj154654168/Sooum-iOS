//
//  SignInResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

import Alamofire


struct SignInResponse: Codable {
    let status: Status
    let isRegistered: Bool
    let token: Token?
    let links: Links?

    enum CodingKeys: String, CodingKey {
        case status
        case isRegistered
        case token
        case links = "_links"
    }
}

extension SignInResponse {
    
    init() {
        self.status = .init()
        self.isRegistered = false
        self.token = nil
        self.links = nil
    }
}

extension SignInResponse: EmptyResponse {
    static func emptyValue() -> SignInResponse {
        SignInResponse.init()
    }
}
