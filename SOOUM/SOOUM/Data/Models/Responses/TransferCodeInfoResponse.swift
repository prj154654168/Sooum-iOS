//
//  TransferCodeInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Alamofire

struct TransferCodeInfoResponse {
    
    let transferInfo: TransferCodeInfo
}

extension TransferCodeInfoResponse: EmptyResponse {
    
    static func emptyValue() -> TransferCodeInfoResponse {
        TransferCodeInfoResponse(transferInfo: TransferCodeInfo.defaultValue)
    }
}

extension TransferCodeInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case transferInfo
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.transferInfo = try singleContainer.decode(TransferCodeInfo.self)
    }
}
