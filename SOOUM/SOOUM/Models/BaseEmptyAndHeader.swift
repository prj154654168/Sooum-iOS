//
//  BaseEmptyAndHeader.swift
//  SOOUM
//
//  Created by 오현식 on 10/21/24.
//

import Foundation

import Alamofire


/// 서버 응답 status
struct Status: Codable {
    let httpCode: Int
    let httpStatus: String
    let responseMessage: String
}

extension Status {
    init() {
        self.httpCode = 0
        self.httpStatus = ""
        self.responseMessage = ""
    }
}

extension Status: EmptyResponse {
    static func emptyValue() -> Status {
        Status.init()
    }
}

/// 실제 urlString
struct URLString: Codable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url = "href"
    }
}
extension URLString {
    init() {
        self.url = ""
    }
}
