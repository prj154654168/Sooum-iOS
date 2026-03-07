//
//  UserRoleInfo.swift
//  SOOUM
//
//  Created by 오현식 on 2/1/26.
//

import Foundation

enum UserRole: String {
    case admin = "ADMIN"
    case user = "USER"
    case banned = "BANNED"
}

extension UserRole: Decodable { }
