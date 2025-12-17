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
        case updateTagCards([ProfileCardInfo])
        case hasDetailCard(String)
        case updateIsFavorite(Bool)
        case cleanup
    }
    
    enum Mutation {
        case tagCardInfos([ProfileCardInfo])
        case moreFind([ProfileCardInfo])
        case cardIsDeleted((String, Bool)?)
        case updateIsFavorite(Bool)
        case updateIsUpdate(Bool?)
        case updateIsRefreshing(Bool)
        case updateHasErrors(Bool?)
    }
    
    struct State {
        fileprivate(set) var tagCardInfos: [ProfileCardInfo]
        fileprivate(set) var cardIsDeleted: (selectedId: String, isDeleted: Bool)?
        fileprivate(set) var isFavorite: Bool
        fileprivate(set) var isUpdated: Bool?
        fileprivate(set) var isRefreshing: Bool
        fileprivate(set) var hasErrors: Bool?
    }
    
    var initialState: State
    
    private let dependencies: AppDIContainerable
    private let fetchCardUseCase: FetchCardUseCase
    private let fetchCardDetailUseCase: FetchCardDetailUseCase
    private let updateTagFavoriteUseCase: UpdateTagFavoriteUseCase
    
    private let id: String
    let title: String
    
    init(dependencies: AppDIContainerable, with id: String, title: String, isFavorite: Bool) {
        self.dependencies = dependencies
        self.fetchCardUseCase = dependencies.rootContainer.resolve(FetchCardUseCase.self)
        self.fetchCardDetailUseCase = dependencies.rootContainer.resolve(FetchCardDetailUseCase.self)
        self.updateTagFavoriteUseCase = dependencies.rootContainer.resolve(UpdateTagFavoriteUseCase.self)
        
        self.id = id
        self.title = title
        
        self.initialState = .init(
            tagCardInfos: [],
            cardIsDeleted: nil,
            isFavorite: isFavorite,
            isUpdated: nil,
            isRefreshing: false,
            hasErrors: nil
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
        case let .updateTagCards(tagCardInfos):
            
            return .just(.tagCardInfos(tagCardInfos))
        case let .hasDetailCard(selectedId):
            
            return .concat([
                .just(.cardIsDeleted(nil)),
                self.fetchCardDetailUseCase.isDeleted(cardId: selectedId)
                .map { (selectedId, $0) }
                .map(Mutation.cardIsDeleted)
            ])
        case let .updateIsFavorite(isFavorite):
            
            return .concat([
                .just(.updateIsUpdate(nil)),
                .just(.updateHasErrors(nil)),
                self.updateTagFavoriteUseCase.updateFavorite(tagId: self.id, isFavorite: !isFavorite)
                    .flatMapLatest { isUpdated -> Observable<Mutation> in
                        
                        let isFavorite = isUpdated ? !isFavorite : isFavorite
                        return .concat([
                            .just(.updateIsFavorite(isFavorite)),
                            .just(.updateIsUpdate(isUpdated))
                        ])
                    }
                    .catch(self.catchClosure)
            ])
        case .cleanup:
            
            return .just(.cardIsDeleted(nil))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .tagCardInfos(tagCardInfos):
            newState.tagCardInfos = tagCardInfos
        case let .moreFind(tagCardInfos):
            newState.tagCardInfos += tagCardInfos
        case let .cardIsDeleted(cardIsDeleted):
            newState.cardIsDeleted = cardIsDeleted
        case let .updateIsFavorite(isFavorite):
            newState.isFavorite = isFavorite
        case let .updateIsUpdate(isUpdated):
            newState.isUpdated = isUpdated
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        case let .updateHasErrors(hasErrors):
            newState.hasErrors = hasErrors
        }
        return newState
    }
}

extension TagCollectViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation>) {
        return { error in
            
            let nsError = error as NSError
            
            if case 400 = nsError.code {
                
                return .just(.updateHasErrors(true))
            }
            
            return .just(.updateIsUpdate(false))
        }
    }
    
    func canPushToDetail(
        prev prevCardIsDeleted: (selectedId: String, isDeleted: Bool)?,
        curr currCardIsDeleted: (selectedId: String, isDeleted: Bool)?
    ) -> Bool {
        return prevCardIsDeleted?.selectedId == currCardIsDeleted?.selectedId &&
            prevCardIsDeleted?.isDeleted == currCardIsDeleted?.isDeleted
    }
}

extension TagCollectViewReactor {
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor(dependencies: self.dependencies, with: selectedId)
    }
}
