//
//  NotificationAllowResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/30/24.
//

import Foundation

import Alamofire


struct NotificationAllowResponse: Codable {
    
    let isAllowNotify: Bool
    let status: Status
}

extension NotificationAllowResponse {
    
    init() {
        self.isAllowNotify = false
        self.status = .init()
    }
}

extension NotificationAllowResponse: EmptyResponse {
    
    static func emptyValue() -> NotificationAllowResponse {
        NotificationAllowResponse.init()
    }
}
