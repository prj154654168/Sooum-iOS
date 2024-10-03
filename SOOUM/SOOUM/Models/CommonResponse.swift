//
//  CommonResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

// MARK: - Links
struct Links: Codable {
    let login: Next?
    let home: Next?
}

// MARK: - Next
struct Next: Codable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url = "href"
    }
}
