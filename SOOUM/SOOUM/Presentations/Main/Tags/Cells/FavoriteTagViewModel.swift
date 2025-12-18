//
//  FavoriteTagViewModel.swift
//  SOOUM
//
//  Created by 오현식 on 11/20/25.
//

import UIKit

class FavoriteTagViewModel {
    
    // let identifier: String
    let id: String
    let text: String
    var isFavorite: Bool
    
    init(
        id: String,
        text: String,
        isFavorite: Bool = true
    ) {
        // self.identifier = UUID().uuidString
        self.id = id
        self.text = text
        self.isFavorite = isFavorite
    }
}

extension FavoriteTagViewModel: Hashable {
    
    static func == (lhs: FavoriteTagViewModel, rhs: FavoriteTagViewModel) -> Bool {
        return /* lhs.identifier == rhs.identifier && */
            lhs.text == rhs.text &&
            lhs.isFavorite == rhs.isFavorite
    }
    
    func hash(into hasher: inout Hasher) {
        // hasher.combine(self.identifier)
        hasher.combine(self.text)
        hasher.combine(self.isFavorite)
    }
}
