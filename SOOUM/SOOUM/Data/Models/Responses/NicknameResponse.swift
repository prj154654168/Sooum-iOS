//
//  NicknameResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/18/25.
//

import Alamofire

struct NicknameResponse {
    
    let nickname: String
}

extension NicknameResponse: EmptyResponse {
    
    static func emptyValue() -> NicknameResponse {
        NicknameResponse(nickname: "")
    }
}

extension NicknameResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case nickname
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nickname = try container.decode(String.self, forKey: .nickname)
    }
}
 
