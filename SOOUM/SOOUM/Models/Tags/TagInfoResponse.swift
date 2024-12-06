//
//  TagInfoResponse.swift
//  SOOUM
//
//  Created by JDeoks on 12/5/24.
//

import Foundation

// MARK: - TagInfoResponse
struct TagInfoResponse: Codable {
    
    // MARK: - Status
    struct Status: Codable {
        let httpCode: Int
        let httpStatus, responseMessage: String
    }
    
    let content: String
    let cardCnt: Int
    let isFavorite: Bool
    let status: Status
}
