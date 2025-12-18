//
//  IsCardDeletedResponse.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/25.
//

import Alamofire

struct IsCardDeletedResponse {
    
    let isDeleted: Bool
}

extension IsCardDeletedResponse: EmptyResponse {
    
    static func emptyValue() -> IsCardDeletedResponse {
        IsCardDeletedResponse(isDeleted: false)
    }
}

extension IsCardDeletedResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case isDeleted
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isDeleted = try container.decode(Bool.self, forKey: .isDeleted)
    }
}
