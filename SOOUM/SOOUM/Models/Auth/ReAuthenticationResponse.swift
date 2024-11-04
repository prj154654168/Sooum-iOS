//
//  ReAuthenticationResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/27/24.
//

import Foundation

import Alamofire


struct ReAuthenticationResponse: Codable {
    let status: Status
    let accessToken: String
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case status
        case accessToken
        case links = "_links"
    }
}

extension ReAuthenticationResponse {
    
    init() {
        self.status = .init()
        self.accessToken = ""
        self.links = .init(login: nil, home: nil)
    }
}

extension ReAuthenticationResponse: EmptyResponse {
    static func emptyValue() -> ReAuthenticationResponse {
        ReAuthenticationResponse.init()
    }
}
