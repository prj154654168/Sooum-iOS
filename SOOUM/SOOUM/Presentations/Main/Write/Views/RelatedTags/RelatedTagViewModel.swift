//
//  RelatedTagViewModel.swift
//  SOOUM
//
//  Created by 오현식 on 10/16/25.
//

import Foundation

class RelatedTagViewModel {
    
    
    // MARK: Variables
    
    let id: String
    let originalText: String
    let count: String
    
    var identifier: AnyHashable {
        self.originalText
    }
    
    
    // MARK: Initialize
    
    init(originalText: String, count: String) {
        self.id = UUID().uuidString
        self.originalText = originalText
        self.count = count
    }
}


// MARK: Hashable

extension RelatedTagViewModel: Hashable {
    
    static func == (lhs: RelatedTagViewModel, rhs: RelatedTagViewModel) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.count == rhs.count
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}
