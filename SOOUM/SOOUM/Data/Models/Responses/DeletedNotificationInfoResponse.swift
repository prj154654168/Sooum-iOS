//
//  DeleteNotificationInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct DeletedNotificationInfoResponse: Hashable, Equatable {
    
    let notificationInfo: CommonNotificationInfo
}

extension DeletedNotificationInfoResponse: EmptyResponse {
    
    static func emptyValue() -> DeletedNotificationInfoResponse {
        DeletedNotificationInfoResponse(notificationInfo: CommonNotificationInfo.defaultValue)
    }
}

extension DeletedNotificationInfoResponse: Decodable {
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.notificationInfo = try singleContainer.decode(CommonNotificationInfo.self)
    }
}
