//
//  SignInResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation


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

extension SignInResponse: EmptyInitializable {
    static func empty() -> SignInResponse {
        return .init(status: .init(), isRegistered: false, token: nil, links: nil)
    }
}
