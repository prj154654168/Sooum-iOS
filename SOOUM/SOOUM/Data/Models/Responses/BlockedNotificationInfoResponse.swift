//
//  BlockedNotificationInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct BlockedNotificationInfoResponse {
    
    let notificationInfo: CommonNotificationInfo
    let blockExpirationDateTime: Date
    
    enum CodingKeys: CodingKey {
        case notificationInfo
        case blockExpirationDateTime
    }
}

extension BlockedNotificationInfoResponse: EmptyResponse {
    
    static func emptyValue() -> BlockedNotificationInfoResponse {
        BlockedNotificationInfoResponse(
            notificationInfo: CommonNotificationInfo.defaultValue,
            blockExpirationDateTime: Date()
        )
    }
}

extension BlockedNotificationInfoResponse: Decodable {
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.notificationInfo = try singleContainer.decode(CommonNotificationInfo.self)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.blockExpirationDateTime = try container.decode(Date.self, forKey: .blockExpirationDateTime)
    }
}
