//
//  WrittenTagModel.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import Foundation

class WrittenTagModel {
    
    
    // MARK: Variables
    
    let id: String
    let originalText: String
    let typography: Typography
    
    var identifier: AnyHashable {
        self.originalText
    }
    
    
    // MARK: Initialize
    
    init(_ id: String, originalText: String, typography: Typography) {
        self.id = id
        self.originalText = originalText
        self.typography = typography
    }
}


// MARK: Hashable

extension WrittenTagModel: Hashable {
    
    static func == (lhs: WrittenTagModel, rhs: WrittenTagModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}
