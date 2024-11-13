//
//  RegisterUserResponse.swift
//  SOOUM
//
//  Created by JDeoks on 11/13/24.
//

import Foundation

struct RegisterUserResponse: Codable {
    
    // MARK: - Status
    struct Status: Codable {
        let code: Int
        let message: String
    }
    
    let status: Status
}

