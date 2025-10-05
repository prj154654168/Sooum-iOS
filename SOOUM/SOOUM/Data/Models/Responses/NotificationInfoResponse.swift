//
//  NotificationInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct NotificationInfoResponse: Hashable, Equatable {
    
    let notificationInfo: CommonNotificationInfo
    let targetCardId: String
    let nickName: String
}

extension NotificationInfoResponse: EmptyResponse {

    static func emptyValue() -> NotificationInfoResponse {
        NotificationInfoResponse(
            notificationInfo: CommonNotificationInfo.defaultValue,
            targetCardId: "",
            nickName: ""
        )
    }
}

extension NotificationInfoResponse: Decodable {
    
    enum CodingKeys: CodingKey {
        case notificationInfo
        case targetCardId
        case nickName
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.notificationInfo = try singleContainer.decode(CommonNotificationInfo.self)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.targetCardId = String(try container.decode(Int64.self, forKey: .targetCardId))
        self.nickName = try container.decode(String.self, forKey: .nickName)
    }
}
