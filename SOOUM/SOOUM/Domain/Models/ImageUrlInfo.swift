//
//  ImageUrlInfo.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation

struct ImageUrlInfo: Equatable {
    
    let imgName: String
    let imgUrl: String
}

extension ImageUrlInfo {
    
    static var defaultValue: ImageUrlInfo = ImageUrlInfo(imgName: "", imgUrl: "")
}

extension ImageUrlInfo: Decodable { }
