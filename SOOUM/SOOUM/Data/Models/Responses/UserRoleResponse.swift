//
//  UserRoleResponse.swift
//  SOOUM
//
//  Created by 오현식 on 2/1/26.
//

import Alamofire

struct UserRoleResponse {
    
    let role: UserRole
    let isTester: Bool
}

extension UserRoleResponse: EmptyResponse {
    
    static func emptyValue() -> UserRoleResponse {
        UserRoleResponse(role: .user, isTester: false)
    }
}

extension UserRoleResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case role
        case isTester
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.role = try container.decode(UserRole.self, forKey: .role)
        self.isTester = try container.decode(Bool.self, forKey: .isTester)
    }
}
