//
//  FollowNotificationInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/25.
//

import Alamofire

struct FollowNotificationInfoResponse: Hashable, Equatable {
    
    let notificationInfo: CommonNotificationInfo
    let nickname: String
    let userId: String
}

extension FollowNotificationInfoResponse: EmptyResponse {
    
    static func emptyValue() -> FollowNotificationInfoResponse {
        FollowNotificationInfoResponse(
            notificationInfo: CommonNotificationInfo.defaultValue,
            nickname: "",
            userId: ""
        )
    }
}

extension FollowNotificationInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case notificationInfo
        case nickname = "nickName"
        case userId
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.notificationInfo = try singleContainer.decode(CommonNotificationInfo.self)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.userId = String(try container.decode(Int64.self, forKey: .userId))
    }
}
