//
//  ReAuthenticationResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/27/24.
//

import Foundation


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

extension ReAuthenticationResponse: EmptyInitializable {
    static func empty() -> ReAuthenticationResponse {
        return .init(status: .init(), accessToken: "", links: .init(login: nil, home: nil))
    }
}