//
//  RSAKeyResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

struct RSAKeyResponse: Codable {
    let status: Status  // 이미 정의된 Status 구조체 사용
    let key: Key
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case status
        case key
        case links = "_links"
    }
}

// 기존에 없는 새로운 구조체들
struct Key: Codable {
    let publicKey: String
}

struct Links: Codable {
    let login: Next 
}
