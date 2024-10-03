//
//  SignupResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

// MARK: - SignupResponse
struct SignupResponse: Codable {
    
    let status: Status
    let token: Token
    let links: Links

    enum CodingKeys: String, CodingKey {
        case status
        case token
        case links = "_links"
    }
    
}
