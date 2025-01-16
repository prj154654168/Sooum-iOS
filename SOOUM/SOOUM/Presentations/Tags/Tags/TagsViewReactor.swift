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
        case moreFind(String)
    }
    
    enum Mutation {
        /// 즐겨찾기 태그 fetch
        case favoriteTags([FavoriteTagsResponse.FavoriteTagList])
        /// 즐겨찾기 태그 more
        case more([FavoriteTagsResponse.FavoriteTagList])
        /// 추천 태그 fetch
        case recommendTags([RecommendTagsResponse.RecommendTag])
        case setLoading(Bool)
        case setProcessing(Bool)
    }
    
    struct State {
        /// 즐겨찾기 태그 리스트
        fileprivate(set) var favoriteTags: [FavoriteTagsResponse.FavoriteTagList] = []
        /// 추천 태그 리스트
        fileprivate(set) var recommendTags: [RecommendTagsResponse.RecommendTag] = []
        fileprivate(set) var isLoading: Bool = false
        fileprivate(set) var isProcessing: Bool = false
    }
    
    var initialState = State()
    var isFavoriteTagsEmpty: Bool {
        self.currentState.favoriteTags.isEmpty
    }
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchTags:
            
            let combined = Observable.concat([
                self.fetchFavoriteTags(),
                self.fetchRecommendTags()
            ])
                .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            
            return .concat([
                .just(.setLoading(true)),
                combined,
                .just(.setLoading(false))
            ])
            
        case let .moreFind(lastId):
            
            return .concat([
                .just(.setProcessing(true)),
                self.fetchFavoriteTags(with: lastId)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.setProcessing(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .favoriteTags(favoriteTags):
            newState.favoriteTags = favoriteTags
            
        case let .more(favoriteTags):
            newState.favoriteTags += favoriteTags
            
        case let .recommendTags(recommendTags):
            newState.recommendTags = recommendTags
            
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .setProcessing(isProcessing):
            newState.isProcessing = isProcessing
        }
        return newState
    }
    
    private func fetchFavoriteTags(with lastId: String? = nil) -> Observable<Mutation> {
        let request: TagRequest = .favorite(last: lastId)
        
        return self.provider.networkManager.request(FavoriteTagsResponse.self, request: request)
            .map(\.embedded.favoriteTagList)
            .map(lastId == nil ? Mutation.favoriteTags : Mutation.more)
            .catch { _ in .just(.favoriteTags([])) }
    }
    
    private func fetchRecommendTags() -> Observable<Mutation> {
        let request: TagRequest = .recommend
        
        return self.provider.networkManager.request(RecommendTagsResponse.self, request: request)
            .map { response in
                return Mutation.recommendTags(response.embedded.recommendTagList)
            }
            .catch { _ in
                return .just(.recommendTags([]))
            }
    }
}

extension TagsViewReactor {
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor(provider: self.provider, selectedId)
    }
    
    func reactorForSearch() -> TagSearchViewReactor {
        TagSearchViewReactor(provider: self.provider)
    }
    
    func reactorForTagDetail(_ tagID: String) -> TagDetailViewrReactor {
        TagDetailViewrReactor(provider: self.provider, tagID: tagID)
    }
}
