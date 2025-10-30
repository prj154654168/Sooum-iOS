//
//  CompositeNotificationInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/25.
//

import Alamofire

struct CompositeNotificationInfoResponse {
    
    let notificationInfo: [CompositeNotificationInfo]
}

extension CompositeNotificationInfoResponse: EmptyResponse {
    
    static func emptyValue() -> CompositeNotificationInfoResponse {
        CompositeNotificationInfoResponse(notificationInfo: [])
    }
}

extension CompositeNotificationInfoResponse: Decodable {
    
    enum CodingKeys: CodingKey {
        case notificationInfo
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.notificationInfo = try singleContainer.decode([CompositeNotificationInfo].self)
    }
}
