//
//  CommonResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation


// MARK: - Links
struct Links: Codable {
    let login: URLString?
    let home: URLString?
}

// MARK: - Token
struct Token: Codable {
    let accessToken: String
    let refreshToken: String
}
