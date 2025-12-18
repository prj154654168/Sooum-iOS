//
//  TagViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 11/18/25.
//

import ReactorKit

class TagViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case refresh
        case favoriteTags
        case updatefavoriteTags([FavoriteTagViewModel])
        case updateIsFavorite(FavoriteTagViewModel)
    }
    
    enum Mutation {
        case favoriteTags([FavoriteTagViewModel])
        case popularTags([TagInfo])
        case updateIsFavorite((FavoriteTagViewModel, Bool)?)
        case updateIsRefreshing(Bool)
    }
    
    struct State {
        fileprivate(set) var favoriteTags: [FavoriteTagViewModel]
        fileprivate(set) var popularTags: [TagInfo]
        @Pulse fileprivate(set) var isUpdatedWithInfo: (model: FavoriteTagViewModel, isUpdated: Bool)?
        fileprivate(set) var isRefreshing: Bool
    }
    
    var initialState: State = .init(
        favoriteTags: [],
        popularTags: [],
        isUpdatedWithInfo: nil,
        isRefreshing: false
    )
    
    private let dependencies: AppDIContainerable
    private let fetchUserInfoUseCase: FetchUserInfoUseCase
    private let fetchTagUseCase: FetchTagUseCase
    private let updateTagFavoriteUseCase: UpdateTagFavoriteUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.fetchUserInfoUseCase = dependencies.rootContainer.resolve(FetchUserInfoUseCase.self)
        self.fetchTagUseCase = dependencies.rootContainer.resolve(FetchTagUseCase.self)
        self.updateTagFavoriteUseCase = dependencies.rootContainer.resolve(UpdateTagFavoriteUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.fetchUserInfoUseCase.myNickname()
                .withUnretained(self)
                .flatMapLatest { object, nickname -> Observable<Mutation> in
                    
                    UserDefaults.standard.nickname = nickname
                    
                    return .concat([
                        object.favoriteTags(),
                        object.popularTags()
                    ])
                }
        case .refresh:
            
            return .concat([
                .just(.updateIsRefreshing(true)),
                self.favoriteTags()
                    .catchAndReturn(.updateIsRefreshing(false)),
                self.popularTags()
                    .catchAndReturn(.updateIsRefreshing(false)),
                .just(.updateIsRefreshing(false))
            ])
        case .favoriteTags:
            
            return self.favoriteTags()
        case let .updatefavoriteTags(models):
            
            return .just(.favoriteTags(models))
        case let .updateIsFavorite(model):
            
            return .concat([
                .just(.updateIsFavorite(nil)),
                self.updateTagFavoriteUseCase.updateFavorite(tagId: model.id, isFavorite: !model.isFavorite)
                    .flatMapLatest { isUpdated -> Observable<Mutation> in
                        return .just(.updateIsFavorite((model, isUpdated)))
                    }
                    .catchAndReturn(.updateIsFavorite((model, false)))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .favoriteTags(favoriteTags):
            newState.favoriteTags = favoriteTags
        case let .popularTags(popularTags):
            newState.popularTags = popularTags
        case let .updateIsFavorite(isUpdatedWithInfo):
            newState.isUpdatedWithInfo = isUpdatedWithInfo
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        }
        return newState
    }
}

private extension TagViewReactor {
    
    func favoriteTags() -> Observable<Mutation> {
        
        return self.fetchTagUseCase.favorites()
            .map { favorites in favorites.map { FavoriteTagViewModel(id: $0.id, text: $0.title) } }
            .map(Mutation.favoriteTags)
    }
    
    func popularTags() -> Observable<Mutation> {
        
        return self.fetchTagUseCase.ranked()
            .map(Mutation.popularTags)
    }
}

extension TagViewReactor {
    
    struct DisplayStates {
        let favoriteTags: [FavoriteTagViewModel]?
        let popularTags: [TagInfo]?
    }
    
    func canUpdateCells(
        prev prevDisplayState: DisplayStates,
        curr currDisplayState: DisplayStates
    ) -> Bool {
        return prevDisplayState.favoriteTags == currDisplayState.favoriteTags &&
            prevDisplayState.popularTags == currDisplayState.popularTags
    }
}

extension TagViewReactor {
    
    func reactorForSearch() -> TagSearchViewReactor {
        TagSearchViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForCollect(with id: String, title: String, isFavorite: Bool) -> TagCollectViewReactor {
        TagCollectViewReactor(dependencies: self.dependencies, with: id, title: title, isFavorite: isFavorite)
    }
}
