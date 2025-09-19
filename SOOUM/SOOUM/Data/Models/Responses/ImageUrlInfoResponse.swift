//
//  ImageUrlInfoResponse.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Alamofire

struct ImageUrlInfoResponse {
    
    let imageUrlInfo: ImageUrlInfo
}

extension ImageUrlInfoResponse: EmptyResponse {
    
    static func emptyValue() -> ImageUrlInfoResponse {
        ImageUrlInfoResponse(imageUrlInfo: ImageUrlInfo.defaultValue)
    }
}

extension ImageUrlInfoResponse: Decodable {
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.imageUrlInfo = try singleContainer.decode(ImageUrlInfo.self)
    }
}
