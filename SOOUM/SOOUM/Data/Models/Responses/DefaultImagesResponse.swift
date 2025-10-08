//
//  DefaultImagesResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Alamofire

struct DefaultImagesResponse {
    let defaultImages: DefaultImages
}

extension DefaultImagesResponse: EmptyResponse {
    
    static func emptyValue() -> DefaultImagesResponse {
        DefaultImagesResponse(defaultImages: DefaultImages.defaultValue)
    }
}

extension DefaultImagesResponse: Decodable {
    
    enum CodingKeys: CodingKey {
        case defaultImages
    }
    
    init(from decoder: any Decoder) throws {
        let singleContainer = try decoder.singleValueContainer()
        self.defaultImages = try singleContainer.decode(DefaultImages.self)
    }
}
