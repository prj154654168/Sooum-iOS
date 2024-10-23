//
//  DefaultCardImageResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/24/24.
//

import Foundation

struct DefaultCardImageResponse: Codable {
    let embedded: Embedded
    let links: Links
    let status: Status

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case links = "_links"
        case status
    }
    
    // MARK: - Embedded
    struct Embedded: Codable {
        let imgURLInfoList: [ImgURLInfoList]

        enum CodingKeys: String, CodingKey {
            case imgURLInfoList = "imgUrlInfoList"
        }
    }

    // MARK: - ImgURLInfoList
    struct ImgURLInfoList: Codable {
        let imgName: String
        let url: Next
    }

    // MARK: - Links
    struct Links: Codable {
        let next: Next
    }
}


