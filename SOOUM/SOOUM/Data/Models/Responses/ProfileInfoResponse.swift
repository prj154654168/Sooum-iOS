//
//  ProfileInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 11/6/25.
//

import Alamofire

struct ProfileInfoResponse {
    
    let profileInfo: ProfileInfo
}

extension ProfileInfoResponse: EmptyResponse {
    
    static func emptyValue() -> ProfileInfoResponse {
        ProfileInfoResponse(profileInfo: ProfileInfo.defaultValue)
    }
}

extension ProfileInfoResponse: Decodable {
    
    enum CodingKeys: CodingKey {
        case profileInfo
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.profileInfo = try singleContainer.decode(ProfileInfo.self)
    }
}
