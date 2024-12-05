//
//  SettingsResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import Foundation

import Alamofire


struct SettingsResponse: Codable {
    let banEndAt: Date?
    let status: Status
}

extension SettingsResponse {
    
    init() {
        self.banEndAt = nil
        self.status = .init()
    }
}

extension SettingsResponse: EmptyResponse {
    static func emptyValue() -> SettingsResponse {
        SettingsResponse.init()
    }
}
