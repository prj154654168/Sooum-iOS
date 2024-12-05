//
//  UpdateNicknameResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import Foundation

import Alamofire


struct UpdateNicknameResponse: Codable {
    let isAvailable: Bool
    let status: Status
}

extension UpdateNicknameResponse {
    
    init() {
        self.isAvailable = false
        self.status = .init()
    }
}

extension UpdateNicknameResponse: EmptyResponse {
    static func emptyValue() -> UpdateNicknameResponse {
        UpdateNicknameResponse.init()
    }
}
