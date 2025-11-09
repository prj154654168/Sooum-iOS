//
//  TransferCodeInfo.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Foundation

struct TransferCodeInfo: Equatable {
    
    let code: String
    let expiredAt: Date
}

extension TransferCodeInfo {
    
    static var defaultValue: TransferCodeInfo = TransferCodeInfo(
        code: "",
        expiredAt: Date()
    )
}

extension TransferCodeInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case code = "transferCode"
        case expiredAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(String.self, forKey: .code)
        self.expiredAt = try container.decode(Date.self, forKey: .expiredAt)
    }
}
