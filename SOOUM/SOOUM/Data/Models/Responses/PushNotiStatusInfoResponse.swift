//
//  PushNotiStatusInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 3/8/26.
//

import Alamofire

struct PushNotiStatusInfoResponse {
    
    let pushNotiStatusInfo: PushNotiStatusInfo
}

extension PushNotiStatusInfoResponse: EmptyResponse {
    
    static func emptyValue() -> PushNotiStatusInfoResponse {
        PushNotiStatusInfoResponse(pushNotiStatusInfo: PushNotiStatusInfo.defaultValue)
    }
}

extension PushNotiStatusInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case pushNotiStatusInfo
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.pushNotiStatusInfo = try singleContainer.decode(PushNotiStatusInfo.self)
    }
}
