//
//  BaseResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import Foundation


protocol BaseCardResponse: Codable {
    
    var embedded: Embedded { get }
    var links: CardResponseLinks { get }
    var status: Status { get }

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
}
