//
//  NoticeInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/25.
//

import Alamofire

struct NoticeInfoResponse {
    
    let noticeInfos: [NoticeInfo]
}

extension NoticeInfoResponse: EmptyResponse {
    
    static func emptyValue() -> NoticeInfoResponse {
        NoticeInfoResponse(noticeInfos: [])
    }
}

extension NoticeInfoResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case noticeInfos = "notices"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.noticeInfos = try container.decode([NoticeInfo].self, forKey: .noticeInfos)
    }
}
