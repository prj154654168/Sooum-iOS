//
//  TagDetailViewrReactor.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import ReactorKit
import RxSwift

class TagDetailViewrReactor: Reactor {
    
    enum Action {
        case fetchCards
    }
    
    enum Mutation {
        /// 즐겨찾기 태그 fetch
        case favoriteTags([FavoriteTagsResponse.FavoriteTagList])
    }
    
}
