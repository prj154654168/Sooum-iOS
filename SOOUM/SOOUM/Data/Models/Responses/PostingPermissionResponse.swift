//
//  PostingPermissionResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/30/25.
//

import Alamofire

struct PostingPermissionResponse {
    
    let postingPermission: PostingPermission
}

extension PostingPermissionResponse: EmptyResponse {
    
    static func emptyValue() -> PostingPermissionResponse {
        PostingPermissionResponse(postingPermission: PostingPermission.defaultValue)
    }
}

extension PostingPermissionResponse: Decodable {
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.postingPermission = try singleContainer.decode(PostingPermission.self)
    }
}
