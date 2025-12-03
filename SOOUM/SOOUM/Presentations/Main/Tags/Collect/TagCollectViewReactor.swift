//
//  TagCollectViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 11/20/25.
//

import ReactorKit

class TagCollectViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case refresh
        case more(String)
        case updateIsFavorite(Bool)
    }
    
    enum Mutation {
        case tagCardInfos([ProfileCardInfo])
        case moreFind([ProfileCardInfo])
        case updateIsFavorite(Bool)
        case updateIsUpdate(Bool?)
        case updateIsRefreshing(Bool)
    }
    
    struct State {
        fileprivate(set) var tagCardInfos: [ProfileCardInfo]
        fileprivate(set) var isFavorite: Bool
        fileprivate(set) var isUpdated: Bool?
        fileprivate(set) var isRefreshing: Bool
    }
    
    var initialState: State
    
    private let dependencies: AppDIContainerable
    private let fetchCardUseCase: FetchCardUseCase
    private let updateTagFavoriteUseCase: UpdateTagFavoriteUseCase
    
    private let id: String
    let title: String
    
    init(dependencies: AppDIContainerable, with id: String, title: String, isFavorite: Bool) {
        self.dependencies = dependencies
        self.fetchCardUseCase = dependencies.rootContainer.resolve(FetchCardUseCase.self)
        self.updateTagFavoriteUseCase = dependencies.rootContainer.resolve(UpdateTagFavoriteUseCase.self)
        
        self.id = id
        self.title = title
        
        self.initialState = .init(
            tagCardInfos: [],
            isFavorite: isFavorite,
            isUpdated: nil,
            isRefreshing: false
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.fetchCardUseCase.cardsWithTag(tagId: self.id, lastId: nil)
                .flatMapLatest { tagCardsInfo -> Observable<Mutation> in
                    
                    let isFavorite = tagCardsInfo.cardInfos.isEmpty ?
                        self.initialState.isFavorite :
                        tagCardsInfo.isFavorite
                    return .concat([
                        .just(.tagCardInfos(tagCardsInfo.cardInfos)),
                        .just(.updateIsFavorite(isFavorite))
                    ])
                }
        case .refresh:
            
            return .concat([
                .just(.updateIsRefreshing(true)),
                self.fetchCardUseCase.cardsWithTag(tagId: self.id, lastId: nil)
                    .flatMapLatest { tagCardsInfo -> Observable<Mutation> in
                        
                        let isFavorite = tagCardsInfo.cardInfos.isEmpty ?
                            self.initialState.isFavorite :
                            tagCardsInfo.isFavorite
                        return .concat([
                            .just(.tagCardInfos(tagCardsInfo.cardInfos)),
                            .just(.updateIsFavorite(isFavorite))
                        ])
                    },
                .just(.updateIsRefreshing(false))
            ])
        case let .more(lastId):
            
            return self.fetchCardUseCase.cardsWithTag(tagId: self.id, lastId: lastId)
                .map(\.cardInfos)
                .map(Mutation.moreFind)
        case let .updateIsFavorite(isFavorite):
            
            return .concat([
                .just(.updateIsUpdate(nil)),
                self.updateTagFavoriteUseCase.updateFavorite(tagId: self.id, isFavorite: !isFavorite)
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
        case let .updateIsFavorite(isFavorite):
            newState.isFavorite = isFavorite
        case let .updateIsUpdate(isUpdated):
            newState.isUpdated = isUpdated
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        }
        return newState
    }
}

extension TagCollectViewReactor {
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor(dependencies: self.dependencies, with: selectedId)
    }
}
