//
//  SOMTagModel.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import UIKit


class SOMTagModel {
    
    let id: String
    let originalText: String
    let count: String?
    let isSelectable: Bool
    let isRemovable: Bool
    
    var identifier: AnyHashable {
        self.originalText
    }
    
    var text: String {
        let text = self.originalText
        return "#\(text)"
    }
    
    init(
        id: String,
        originalText: String,
        count: String? = nil,
        isSelectable: Bool = false,
        isRemovable: Bool
    ) {
        self.id = id
        self.originalText = originalText
        self.count = count
        self.isSelectable = isSelectable
        self.isRemovable = isRemovable
    }
}

extension SOMTagModel: Hashable {
    
    static func == (lhs: SOMTagModel, rhs: SOMTagModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}
