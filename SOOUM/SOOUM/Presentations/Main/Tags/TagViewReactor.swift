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
    private let tagUseCase: TagUseCase
    private let userUseCase: UserUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.tagUseCase = dependencies.rootContainer.resolve(TagUseCase.self)
        self.userUseCase = dependencies.rootContainer.resolve(UserUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.userUseCase.profile(userId: nil)
                .map(\.nickname)
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
                self.tagUseCase.updateFavorite(tagId: model.id, isFavorite: !model.isFavorite)
                    .flatMapLatest { isUpdated -> Observable<Mutation> in .just(.updateIsFavorite((model, isUpdated))) }
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
        
        return self.tagUseCase.favorites()
            // 관심 태그는 최대 9개까지 표시
            .map { Array($0.prefix(9)).map { FavoriteTagViewModel(id: $0.id, text: $0.title) } }
            .map(Mutation.favoriteTags)
    }
    
    func popularTags() -> Observable<Mutation> {
        
        return self.tagUseCase.ranked()
            // 인기 태그는 최소 1개 이상일 때 표시
            .map { $0.filter { $0.usageCnt > 0 } }
            // // 중복 제거
            // .map { Array(Set($0)) }
            // // 태그 갯수로 정렬
            // .map { $0.sorted(by: { $0.usageCnt > $1.usageCnt }) }
            // 인기 태그는 최대 10개까지 표시
            .map { Array($0.prefix(10)) }
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
