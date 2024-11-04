//
//  RSAKeyResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/1/24.
//

import Foundation

import Alamofire


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

extension RSAKeyResponse {
    
    init() {
        self.status = .init()
        self.publicKey = ""
        self.links = .init(login: nil, home: nil)
    }
}

extension RSAKeyResponse: EmptyResponse {
    static func emptyValue() -> RSAKeyResponse {
        RSAKeyResponse.init()
    }
}
