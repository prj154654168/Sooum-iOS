//
//  RSAKeyResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

struct RSAKeyResponse: Codable {
    let status: Status
    let key: Key?
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case status
        case key
        case links = "_links"
    }
}

struct Key: Codable {
    let publicKey: String
}
