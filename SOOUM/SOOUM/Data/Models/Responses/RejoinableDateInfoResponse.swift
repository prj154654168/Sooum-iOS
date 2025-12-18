//
//  RejoinableDateInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/13/25.
//

import Alamofire

struct RejoinableDateInfoResponse {
    
    let rejoinableDate: RejoinableDateInfo
}

extension RejoinableDateInfoResponse: EmptyResponse {
    
    static func emptyValue() -> RejoinableDateInfoResponse {
        RejoinableDateInfoResponse(rejoinableDate: RejoinableDateInfo.defaultValue)
    }
}

extension RejoinableDateInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case rejoinableDate
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.rejoinableDate = try singleContainer.decode(RejoinableDateInfo.self)
    }
}
