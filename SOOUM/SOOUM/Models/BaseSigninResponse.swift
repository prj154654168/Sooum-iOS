//
//  BaseSigninResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

// MARK: - Token
struct Token: Codable {
    let accessToken: String
    let refreshToken: String
}
