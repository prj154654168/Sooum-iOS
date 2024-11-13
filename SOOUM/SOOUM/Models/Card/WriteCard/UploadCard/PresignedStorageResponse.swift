//
//  PresignedStorageResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/25/24.
//

import Foundation

import Alamofire

// MARK: - PresignedStorageResponse
struct PresignedStorageResponse: Codable {
    let imgName: String
    let url: URLClass
    let status: Status
    
    // MARK: - URLClass
    struct URLClass: Codable {
        let href: String
    }
}

extension PresignedStorageResponse: EmptyResponse {
    static func emptyValue() -> PresignedStorageResponse {
        PresignedStorageResponse.init(imgName: "", url: .init(href: ""), status: .init())
    }
}
