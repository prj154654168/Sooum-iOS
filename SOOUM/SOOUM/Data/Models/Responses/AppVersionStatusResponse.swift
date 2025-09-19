//
//  AppVersionStatusResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct AppVersionStatusResponse {
    
    let version: Version
}

extension AppVersionStatusResponse: EmptyResponse {
    
    static func emptyValue() -> AppVersionStatusResponse {
        return AppVersionStatusResponse(version: Version.defaultValue)
    }
}

extension AppVersionStatusResponse: Decodable {
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.version = try singleContainer.decode(Version.self)
    }
}
