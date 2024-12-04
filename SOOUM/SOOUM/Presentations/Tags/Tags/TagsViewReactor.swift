//
//  TagsViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import Foundation

import ReactorKit

class TagsViewReactor: Reactor {
    
    enum Action {
        case fetchTags
    }
    
    enum Mutation {
        /// 즐겨찾기 태그 fetch
        case favoriteTags([FavoriteTagsResponse.FavoriteTagList])
        /// 추천 태그 fetch
        case recommendTags([RecommendTagsResponse.RecommendTagList])
    }
    
    struct State {
        /// 즐겨찾기 태그 리스트
        fileprivate(set) var favoriteTags: [FavoriteTagsResponse.FavoriteTagList] = []
        /// 추천 태그 리스트
        fileprivate(set) var recommendTags: [RecommendTagsResponse.RecommendTagList] = []
    }
    
    var initialState = State()
    
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
    
    private func fetchFavoriteTags() -> Observable<Mutation> {
        let request: TagRequest = .favorite(last: nil)
        
        return NetworkManager.shared.request(FavoriteTagsResponse.self, request: request)
            .map { response in
                return Mutation.favoriteTags(response.embedded.favoriteTagList)
            }
            .catch { _ in
                print("\(type(of: self)) - \(#function) - catch")
                return .just(.favoriteTags([]))
            }
    }
    
    private func fetchRecommendTags() -> Observable<Mutation> {
        let request: TagRequest = .recommend
        
        return NetworkManager.shared.request(RecommendTagsResponse.self, request: request)
            .map { response in
                return Mutation.recommendTags(response.embedded.recommendTagList)
            }
            .catch { _ in
                print("\(type(of: self)) - \(#function) - catch")
                return .just(.recommendTags([]))
            }
    }
}