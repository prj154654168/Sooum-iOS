//
//  TagSearchCollectViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 11/24/25.
//

import ReactorKit

class TagSearchCollectViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case refresh
        case more(String)
        case updateIsFavorite(Bool)
    }
    
    enum Mutation {
        case tagCardInfos([ProfileCardInfo])
        case moreFind([ProfileCardInfo])
        case updateIsUpdate(Bool?)
        case updateIsFavorite(Bool)
        case updateIsRefreshing(Bool)
    }
    
    struct State {
        fileprivate(set) var tagCardInfos: [ProfileCardInfo]
        fileprivate(set) var isUpdated: Bool?
        fileprivate(set) var isFavorite: Bool
        fileprivate(set) var isRefreshing: Bool
    }
    
    var initialState: State = .init(
        tagCardInfos: [],
        isUpdated: nil,
        isFavorite: false,
        isRefreshing: false
    )
    
    private let dependencies: AppDIContainerable
    private let fetchCardUseCase: FetchCardUseCase
    private let fetchTagUseCase: FetchTagUseCase
    private let updateTagFavoriteUseCase: UpdateTagFavoriteUseCase
    
    private let tagId: String
    let title: String
    
    init(dependencies: AppDIContainerable, with tagId: String, title: String) {
        self.dependencies = dependencies
        self.fetchCardUseCase = dependencies.rootContainer.resolve(FetchCardUseCase.self)
        self.fetchTagUseCase = dependencies.rootContainer.resolve(FetchTagUseCase.self)
        self.updateTagFavoriteUseCase = dependencies.rootContainer.resolve(UpdateTagFavoriteUseCase.self)
        
        self.tagId = tagId
        self.title = title
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.cardsWithTag(with: nil)
                .catchAndReturn(.tagCardInfos([]))
        case .refresh:
            
            return .concat([
                .just(.updateIsRefreshing(true)),
                self.cardsWithTag(with: nil)
                    .catchAndReturn(.tagCardInfos([])),
                .just(.updateIsRefreshing(false))
            ])
        case let .more(lastId):
            
            return self.fetchCardUseCase.cardsWithTag(tagId: self.tagId, lastId: lastId)
                .map(\.cardInfos)
                .map(Mutation.moreFind)
        case let .updateIsFavorite(isFavorite):
            
            return .concat([
                .just(.updateIsUpdate(nil)),
                self.updateTagFavoriteUseCase.updateFavorite(tagId: self.tagId, isFavorite: !isFavorite)
                    .flatMapLatest { isUpdated -> Observable<Mutation> in
                        
                        let isFavorite = isUpdated ? !isFavorite : isFavorite
                        return .concat([
                            .just(.updateIsFavorite(isFavorite)),
                            .just(.updateIsUpdate(isUpdated))
                        ])
                    }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .tagCardInfos(tagCardInfos):
            newState.tagCardInfos = tagCardInfos
        case let .moreFind(tagCardInfos):
            newState.tagCardInfos += tagCardInfos
        case let .updateIsUpdate(isUpdated):
            newState.isUpdated = isUpdated
        case let .updateIsFavorite(isFavorite):
            newState.isFavorite = isFavorite
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        }
        return newState
    }
}

private extension TagSearchCollectViewReactor {
    
    func cardsWithTag(with lastId: String?) -> Observable<Mutation> {
        
        return self.fetchCardUseCase.cardsWithTag(tagId: self.tagId, lastId: nil)
            .withUnretained(self)
            .flatMapLatest { object, tagCardsInfo -> Observable<Mutation> in
                
                if tagCardsInfo.cardInfos.isEmpty {
                    let tagInfo = FavoriteTagInfo(id: object.tagId, title: object.title)
                    return object.fetchTagUseCase.isFavorites(with: tagInfo)
                        .flatMapLatest { isFavorite -> Observable<Mutation> in
                            
                            return .concat([
                                .just(.tagCardInfos(tagCardsInfo.cardInfos)),
                                .just(.updateIsFavorite(isFavorite))
                            ])
                        }
                }
                
                return .concat([
                    .just(.tagCardInfos(tagCardsInfo.cardInfos)),
                    .just(.updateIsFavorite(tagCardsInfo.isFavorite))
                ])
            }
    }
}

extension TagSearchCollectViewReactor {
    
    func reactorForDetail(with id: String) -> DetailViewReactor {
        DetailViewReactor(dependencies: self.dependencies, with: id)
    }
}
