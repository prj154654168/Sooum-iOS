//
//  SignUpRequest.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct SignUpRequest: Encodable {
    
    let memberInfo: MemberInfo
    let policy: Policy
}
