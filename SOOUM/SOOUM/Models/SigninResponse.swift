//
//  SigninResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

// MARK: - SigninResponse
struct SigninResponse: Codable {
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



// MARK: - SignupLink
struct SignupLink: Codable {
    let href: String
}
