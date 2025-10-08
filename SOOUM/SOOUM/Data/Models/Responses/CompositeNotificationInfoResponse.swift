//
//  CompositeNotificationInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/25.
//

import Alamofire

struct CompositeNotificationInfoResponse: Decodable {
    
    let notificationInfo: [CompositeNotificationInfo]
}

extension CompositeNotificationInfoResponse: EmptyResponse {
    
    static func emptyValue() -> CompositeNotificationInfoResponse {
        CompositeNotificationInfoResponse(notificationInfo: [])
    }
}
