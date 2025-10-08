//
//  TagInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Alamofire

struct TagInfoResponse {
    let tagInfos: [TagInfo]
}

extension TagInfoResponse: EmptyResponse {
    
    static func emptyValue() -> TagInfoResponse {
        TagInfoResponse(tagInfos: [])
    }
}

extension TagInfoResponse: Decodable {
    
    enum CodingKeys: CodingKey {
        case tagInfos
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.tagInfos = try singleContainer.decode([TagInfo].self)
    }
}
