//
//  WriteCardTagModel.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

class WriteCardTagModel {
    
    
    // MARK: Variables
    
    let id: String
    let originalText: String
    var typography: Typography
    
    var identifier: AnyHashable {
        self.originalText
    }
    
    
    // MARK: Initialize
    
    init(originalText: String, typography: Typography) {
        self.id = UUID().uuidString
        self.originalText = originalText
        self.typography = typography
    }
}


// MARK: Hashable

extension WriteCardTagModel: Hashable {
    
    static func == (lhs: WriteCardTagModel, rhs: WriteCardTagModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}
