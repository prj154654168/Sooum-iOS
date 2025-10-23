//
//  SOMPageModel.swift
//  SOOUM
//
//  Created by 오현식 on 10/2/25.
//

import UIKit


class SOMPageModel {
    
    let data: NoticeInfo
    
    init(data: NoticeInfo) {
        self.data = data
    }
}

extension SOMPageModel: Hashable {
    
    static func == (lhs: SOMPageModel, rhs: SOMPageModel) -> Bool {
        return lhs.data.id == rhs.data.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.data.id)
    }
}
