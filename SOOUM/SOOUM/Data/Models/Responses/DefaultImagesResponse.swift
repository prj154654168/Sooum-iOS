//
//  DefaultImagesResponse.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Alamofire

struct DefaultImagesResponse: Decodable {
    let defaultImages: DefaultImages
}

extension DefaultImagesResponse: EmptyResponse {
    
    static func emptyValue() -> DefaultImagesResponse {
        DefaultImagesResponse(defaultImages: DefaultImages.defaultValue)
    }
}
