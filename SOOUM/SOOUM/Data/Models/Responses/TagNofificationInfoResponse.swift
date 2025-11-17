//
//  TagNofificationInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/13/25.
//

import Alamofire

struct TagNofificationInfoResponse: Hashable, Equatable {
    
    let notificationInfo: CommonNotificationInfo
    let targetCardId: String
    let tagContent: String
}

extension TagNofificationInfoResponse: EmptyResponse {
    
    static func emptyValue() -> TagNofificationInfoResponse {
        TagNofificationInfoResponse(
            notificationInfo: CommonNotificationInfo.defaultValue,
            targetCardId: "",
            tagContent: ""
        )
    }
}

extension TagNofificationInfoResponse: Decodable {
    
    enum CodingKeys: CodingKey {
        case notificationInfo
        case targetCardId
        case tagContent
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.notificationInfo = try singleContainer.decode(CommonNotificationInfo.self)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.targetCardId = String(try container.decode(Int64.self, forKey: .targetCardId))
        self.tagContent = try container.decode(String.self, forKey: .tagContent)
    }
}
