//
//  FavoriteTagsViewModel.swift
//  SOOUM
//
//  Created by 오현식 on 11/25/25.
//

import UIKit

class FavoriteTagsViewModel {
    
    let identifier: String
    var tags: [FavoriteTagViewModel]
    
    init(tags: [FavoriteTagViewModel]) {
        self.identifier = UUID().uuidString
        self.tags = tags
    }
}

extension FavoriteTagsViewModel: Hashable {
    
    static func == (lhs: FavoriteTagsViewModel, rhs: FavoriteTagsViewModel) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.tags == rhs.tags
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
        hasher.combine(self.tags)
    }
}
