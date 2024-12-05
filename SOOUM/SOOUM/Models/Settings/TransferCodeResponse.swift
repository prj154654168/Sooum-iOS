//
//  TransferCodeResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import Foundation

import Alamofire


struct TransferCodeResponse: Codable {
    let transferCode: String
    let status: Status
}

extension TransferCodeResponse {
    
    init() {
        self.transferCode = ""
        self.status = .init()
    }
}

extension TransferCodeResponse: EmptyResponse {
    static func emptyValue() -> TransferCodeResponse {
        TransferCodeResponse.init()
    }
}
