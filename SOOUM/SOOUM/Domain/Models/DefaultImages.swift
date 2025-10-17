//
//  DefaultImages.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

struct DefaultImages: Equatable {
    let abstract: [ImageUrlInfo]
    let nature: [ImageUrlInfo]
    let sensitivity: [ImageUrlInfo]
    let food: [ImageUrlInfo]
    let color: [ImageUrlInfo]
    let memo: [ImageUrlInfo]
}

extension DefaultImages {
    
    static var defaultValue: DefaultImages = DefaultImages(
        abstract: [],
        nature: [],
        sensitivity: [],
        food: [],
        color: [],
        memo: []
    )
}

extension DefaultImages: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case abstract = "ABSTRACT"
        case nature = "NATURE"
        case sensitivity = "SENSITIVITY"
        case food = "FOOD"
        case color = "COLOR"
        case memo = "MEMO"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.abstract = try container.decode([ImageUrlInfo].self, forKey: .abstract)
        self.nature = try container.decode([ImageUrlInfo].self, forKey: .nature)
        self.sensitivity = try container.decode([ImageUrlInfo].self, forKey: .sensitivity)
        self.food = try container.decode([ImageUrlInfo].self, forKey: .food)
        self.color = try container.decode([ImageUrlInfo].self, forKey: .color)
        self.memo = try container.decode([ImageUrlInfo].self, forKey: .memo)
    }
}
