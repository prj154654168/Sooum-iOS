//
//  NicknameValidationResponse.swift
//  SOOUM
//
//  Created by JDeoks on 11/7/24.
//

import Foundation

struct NicknameValidationResponse: Decodable {
    let isAvailable: Bool
    let status: Status
    
    struct Status: Decodable {
        let httpCode: Int
        let httpStatus: String
        let responseMessage: String
    }
}
