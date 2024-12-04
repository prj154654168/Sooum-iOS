//
//  TagSearchViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import ReactorKit

class TagSearchViewReactor: Reactor {
    
    enum Action {
        case searchTag(String)
        case selectTag(String)
    }
    
    enum Mutation {
        /// 즐겨찾기 태그 fetch
        case searchTags([])
        case setSelectTagFinished
    }
    
    struct State {
        /// 즐겨찾기 태그 리스트
        fileprivate(set) var searchTags: [FavoriteTagsResponse.FavoriteTagList] = []
        /// 추천 태그 리스트
        fileprivate(set) var recommendTags: [RecommendTagsResponse.RecommendTag] = []
    }
    
    var initialState = State()
    var isFavoriteTagsEmpty: Bool {
        self.currentState.favoriteTags.isEmpty
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchTags:
            return .concat([
                self.fetchFavoriteTags(),
                self.fetchRecommendTags()
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .favoriteTags(favoriteTags):
            newState.favoriteTags = favoriteTags
            
        case let .recommendTags(recommendTags):
            newState.recommendTags = recommendTags
        }
        return newState
    }
}
