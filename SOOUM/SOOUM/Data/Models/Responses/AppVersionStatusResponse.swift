//
//  AppVersionStatusResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct AppVersionStatusResponse: Decodable {
    
    let version: Version
}

extension AppVersionStatusResponse: EmptyResponse {
    
    static func emptyValue() -> AppVersionStatusResponse {
        return AppVersionStatusResponse(version: Version.defaultValue)
    }
}
