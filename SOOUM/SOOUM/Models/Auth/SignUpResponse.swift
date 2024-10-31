//
//  SignUpResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation


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

extension SignUpResponse: EmptyInitializable {
    static func empty() -> SignUpResponse {
        return .init(
            status: .init(),
            token: .init(accessToken: "", refreshToken: ""),
            links: .init(login: nil, home: nil)
        )
    }
}
