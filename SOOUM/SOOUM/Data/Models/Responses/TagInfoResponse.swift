//
//  TagInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Alamofire

struct TagInfoResponse: Decodable {
    let tagInfos: [TagInfo]
}

extension TagInfoResponse: EmptyResponse {
    
    static func emptyValue() -> TagInfoResponse {
        TagInfoResponse(tagInfos: [])
    }
}
