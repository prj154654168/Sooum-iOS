//
//  myCardInfo.swift
//  SOOUM
//
//  Created by 오현식 on 11/6/25.
//

import Foundation

struct ProfileCardInfo: Hashable {
    
    let id: String
    let imgName: String
    let imgURL: String
    let content: String
    let font: BaseCardInfo.Font
}

extension ProfileCardInfo {
    
    static var defaultValue: ProfileCardInfo = ProfileCardInfo(
        id: "",
        imgName: "",
        imgURL: "",
        content: "",
        font: .pretendard
    )
}

extension ProfileCardInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id = "cardId"
        case imgName = "cardImgName"
        case imgURL = "cardImgUrl"
        case content = "cardContent"
        case font
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = String(try container.decode(Int64.self, forKey: .id))
        self.imgName = try container.decode(String.self, forKey: .imgName)
        self.imgURL = try container.decode(String.self, forKey: .imgURL)
        self.content = try container.decode(String.self, forKey: .content)
        self.font = try container.decode(BaseCardInfo.Font.self, forKey: .font)
    }
}
