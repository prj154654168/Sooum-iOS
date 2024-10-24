//
//  PresignedStorageResponse.swift
//  SOOUM
//
//  Created by JDeoks on 10/25/24.
//

import Foundation

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


