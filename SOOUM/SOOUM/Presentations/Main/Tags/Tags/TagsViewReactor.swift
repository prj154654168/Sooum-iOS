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
        case initialize
        case refresh
        case loadMoreFavorite
    }
    
    enum Mutation {
        /// 즐겨찾기 태그 fetch
        case setFavoriteTags([FavoriteTagsResponse.FavoriteTagList])
        /// 즐겨찾기 태그 more
        case appendFavoriteTags([FavoriteTagsResponse.FavoriteTagList])
        /// 추천 태그 fetch
        case setRecommendTags([RecommendTagsResponse.RecommendTag])
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
    
    private var lastID: String?
    private var isFetching = false
    private let pageSize = 20
    private var isLastPage = false
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        print("@@@", action)
        switch action {
            
        case .initialize:
            isFetching = false
            isLastPage = false
            lastID = nil
            let zipped = Observable.concat([
                self.fetchFavoriteTags(),
                self.fetchRecommendTags()
            ])
            return .concat([
                .just(.setLoading(true)),
                zipped,
                .just(.setLoading(false))
            ])
            
        case .refresh:
            isFetching = false
            isLastPage = false
            lastID = nil
            let zipped = Observable.concat([
                self.fetchFavoriteTags(),
                self.fetchRecommendTags()
            ])
                .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            
            return .concat([
                .just(.setLoading(true)),
                zipped,
                .just(.setLoading(false))
            ])
            
        case .loadMoreFavorite:
            guard !isFetching, !isLastPage else {
                return .empty()
            }
            return .concat([
                .just(.setProcessing(true)),
                self.fetchFavoriteTags(with: currentState.favoriteTags.last?.id),
                .just(.setProcessing(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setFavoriteTags(favoriteTags):
            newState.favoriteTags = favoriteTags
            
        case let .appendFavoriteTags(favoriteTags):
            newState.favoriteTags += favoriteTags
            
        case let .setRecommendTags(recommendTags):
            newState.recommendTags = recommendTags
            
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .setProcessing(isProcessing):
            newState.isProcessing = isProcessing
        }
        print("@@@", state.favoriteTags.count)
        return newState
    }
    
    private func fetchFavoriteTags(with lastId: String? = nil) -> Observable<Mutation> {
        guard !isFetching, !isLastPage else {
            return .empty()
        }
        
        isFetching = true
        
        let request: TagRequest = .favorite(last: lastId)
        
        return self.provider.networkManager.request(FavoriteTagsResponse.self, request: request)
            .map { response -> Mutation in
                let items = response.embedded.favoriteTagList
                self.isFetching = false
                return lastId == nil ? .setFavoriteTags(items) : .appendFavoriteTags(items)
            }
            .catch { _ in
                self.isFetching = false
                self.isLastPage = true
                return .empty()
            }
    }
    
    private func fetchRecommendTags() -> Observable<Mutation> {
        print("\(type(of: self)) - \(#function)", action)
        
        let request: TagRequest = .recommend
        
        return self.provider.networkManager.request(RecommendTagsResponse.self, request: request)
            .map { response in
                return Mutation.setRecommendTags(response.embedded.recommendTagList)
            }
            .catch { _ in
                return .just(.setRecommendTags([]))
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
