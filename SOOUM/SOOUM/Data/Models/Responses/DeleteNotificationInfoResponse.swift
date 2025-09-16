//
//  DeleteNotificationInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct DeleteNotificationInfoResponse {
    
    let notificationInfo: CommonNotificationInfo
}

extension DeleteNotificationInfoResponse: EmptyResponse {
    
    static func emptyValue() -> DeleteNotificationInfoResponse {
        DeleteNotificationInfoResponse(notificationInfo: CommonNotificationInfo.defaultValue)
    }
}

extension DeleteNotificationInfoResponse: Decodable {
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.notificationInfo = try singleContainer.decode(CommonNotificationInfo.self)
    }
}
