//
//  RSAKeyResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation


struct RSAKeyResponse: Codable {
    let status: Status
    let publicKey: String
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case status
        case publicKey
        case links = "_links"
    }
}

extension RSAKeyResponse: EmptyInitializable {
    static func empty() -> RSAKeyResponse {
        return .init(status: .init(), publicKey: "", links: .init(login: nil, home: nil))
    }
}
