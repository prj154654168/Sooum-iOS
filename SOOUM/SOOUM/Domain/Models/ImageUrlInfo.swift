//
//  ImageUrlInfo.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation

struct ImageUrlInfo: Hashable {
    
    let imgName: String
    let imgUrl: String
}

extension ImageUrlInfo {
    
    static var defaultValue: ImageUrlInfo = ImageUrlInfo(imgName: "", imgUrl: "")
}

extension ImageUrlInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case imgName
        case imgUrl
        case url
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.imgName = try container.decode(String.self, forKey: .imgName)
        
        if let imgUrl = try? container.decode(String.self, forKey: .imgUrl) {
            self.imgUrl = imgUrl
        } else if let url = try? container.decode(String.self, forKey: .url) {
            self.imgUrl = url
        } else {
            throw DecodingError.keyNotFound(
                CodingKeys.imgUrl,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "imgUrl or url not found"
                )
            )
        }
    }
}
