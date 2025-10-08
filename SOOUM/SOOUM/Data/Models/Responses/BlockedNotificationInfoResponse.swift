//
//  BlockedNotificationInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct BlockedNotificationInfoResponse: Hashable, Equatable {
    
    let notificationInfo: CommonNotificationInfo
    let blockExpirationDateTime: Date
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
    
    enum CodingKeys: CodingKey {
        case notificationInfo
        case blockExpirationDateTime
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.notificationInfo = try singleContainer.decode(CommonNotificationInfo.self)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.blockExpirationDateTime = try container.decode(Date.self, forKey: .blockExpirationDateTime)
    }
}
