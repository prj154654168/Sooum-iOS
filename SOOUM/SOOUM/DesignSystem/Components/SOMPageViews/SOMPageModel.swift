//
//  SOMPageModel.swift
//  SOOUM
//
//  Created by 오현식 on 10/2/25.
//

import UIKit


class SOMPageModel {
    
    let id: String
    let data: NoticeInfo
    
    init(data: NoticeInfo) {
        self.id = UUID().uuidString
        self.data = data
    }
}

extension SOMPageModel: Hashable {
    
    static func == (lhs: SOMPageModel, rhs: SOMPageModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
