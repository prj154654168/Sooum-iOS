//
//  TagSearchViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 11/22/25.
//

import ReactorKit

class TagSearchViewReactor: Reactor {
    
    enum Action: Equatable {
        // 검색어 조회
        case search(String)
        // 태그 모아보기
        case cardsWithTag(TagInfoForCard)
        case refresh
        case more(String)
        case updateTagCards([ProfileCardInfo])
        case hasDetailCard(String)
        case updateIsFavorite(Bool)
        case cleanup(CleanupFor)
    }
    
    enum Mutation {
        case searchTerms([TagInfo]?)
        case selectedTagInfo(TagInfoForCard?)
        case tagCardInfos([ProfileCardInfo]?)
        case moreFind([ProfileCardInfo])
        case cardIsDeleted((String, Bool)?)
        case updateIsUpdated(Bool?)
        case updateIsFavorite(Bool)
        case updateIsRefreshing(Bool)
        case updateHasErrors(Bool?)
    }
    
    struct State {
        fileprivate(set) var searchTerms: [TagInfo]?
        fileprivate(set) var selectedTagInfo: TagInfoForCard?
        fileprivate(set) var tagCardInfos: [ProfileCardInfo]?
        fileprivate(set) var cardIsDeleted: (selectedId: String, isDeleted: Bool)?
        fileprivate(set) var isUpdated: Bool?
        fileprivate(set) var isFavorite: Bool
        fileprivate(set) var isRefreshing: Bool
        fileprivate(set) var hasErrors: Bool?
    }
    
    var initialState: State = .init(
        searchTerms: nil,
        selectedTagInfo: nil,
        tagCardInfos: nil,
        cardIsDeleted: nil,
        isUpdated: nil,
        isFavorite: false,
        isRefreshing: false,
        hasErrors: nil
    )
    
    private let dependencies: AppDIContainerable
    private let fetchTagUseCase: FetchTagUseCase
    private let fetchCardUseCase: FetchCardUseCase
    private let fetchCardDetailUseCase: FetchCardDetailUseCase
    private let updateTagFavoriteUseCase: UpdateTagFavoriteUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.fetchTagUseCase = dependencies.rootContainer.resolve(FetchTagUseCase.self)
        self.fetchCardUseCase = dependencies.rootContainer.resolve(FetchCardUseCase.self)
        self.fetchCardDetailUseCase = dependencies.rootContainer.resolve(FetchCardDetailUseCase.self)
        self.updateTagFavoriteUseCase = dependencies.rootContainer.resolve(UpdateTagFavoriteUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .search(terms):
            
            return self.fetchTagUseCase.related(keyword: terms, size: 20)
                .map(Mutation.searchTerms)
        case let .cardsWithTag(tagInfo):
            
            return .concat([
                .just(.selectedTagInfo(tagInfo)),
                self.cardsWithTag(tagInfo, with: nil)
                    .catchAndReturn(.tagCardInfos([]))
            ])
        case .refresh:
            
            guard let tagInfo = self.currentState.selectedTagInfo else { return .empty() }
            
            return .concat([
                .just(.updateIsRefreshing(true)),
                self.cardsWithTag(tagInfo, with: nil)
                    .catchAndReturn(.tagCardInfos([])),
                .just(.updateIsRefreshing(false))
            ])
        case let .more(lastId):
            
            guard let tagInfo = self.currentState.selectedTagInfo else { return .empty() }
            
            return self.fetchCardUseCase.cardsWithTag(tagId: tagInfo.id, lastId: lastId)
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
        case let .updateIsFavorite( isFavorite):
            
            guard let tagInfo = self.currentState.selectedTagInfo else { return .empty() }
            
            return .concat([
                .just(.updateIsUpdated(nil)),
                .just(.updateHasErrors(nil)),
                self.updateTagFavoriteUseCase.updateFavorite(tagId: tagInfo.id, isFavorite: !isFavorite)
                    .flatMapLatest { isUpdated -> Observable<Mutation> in
                        
                        let isFavorite = isUpdated ? !isFavorite : isFavorite
                        return .concat([
                            .just(.updateIsFavorite(isFavorite)),
                            .just(.updateIsUpdated(isUpdated))
                        ])
                    }
                    .catch(self.catchClosure)
            ])
        case let .cleanup(cleanupFor):
            
            switch cleanupFor {
            case .push: return .just(.cardIsDeleted(nil))
            case .search: return .just(.searchTerms(nil))
            case .tagCard: return .just(.tagCardInfos(nil))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .searchTerms(searchTerms):
            newState.searchTerms = searchTerms
        case let .selectedTagInfo(selectedTagInfo):
            newState.selectedTagInfo = selectedTagInfo
        case let .tagCardInfos(tagCardInfos):
            newState.tagCardInfos = tagCardInfos
        case let .moreFind(tagCardInfos):
            newState.tagCardInfos? += tagCardInfos
        case let .cardIsDeleted(cardIsDeleted):
            newState.cardIsDeleted = cardIsDeleted
        case let .updateIsUpdated(isUpdated):
            newState.isUpdated = isUpdated
        case let .updateIsFavorite(isFavorite):
            newState.isFavorite = isFavorite
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        case let .updateHasErrors(hasErrors):
            newState.hasErrors = hasErrors
        }
        return newState
    }
}

private extension TagSearchViewReactor {
    
    func cardsWithTag(_ tagInfo: TagInfoForCard, with lastId: String?) -> Observable<Mutation> {
        
        return self.fetchCardUseCase.cardsWithTag(tagId: tagInfo.id, lastId: nil)
            .withUnretained(self)
            .flatMapLatest { object, tagCardsInfo -> Observable<Mutation> in
                
                if tagCardsInfo.cardInfos.isEmpty {
                    let tagInfo = FavoriteTagInfo(id: tagInfo.id, title: tagInfo.title)
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
    
    var catchClosure: ((Error) throws -> Observable<Mutation>) {
        return { error in
            
            let nsError = error as NSError
            
            if case 400 = nsError.code {
                
                return .just(.updateHasErrors(true))
            }
            
            return .just(.updateIsUpdated(false))
        }
    }
}

extension TagSearchViewReactor {
    
    func canPushToDetail(
        prev prevCardIsDeleted: (selectedId: String, isDeleted: Bool)?,
        curr currCardIsDeleted: (selectedId: String, isDeleted: Bool)?
    ) -> Bool {
        return prevCardIsDeleted?.selectedId == currCardIsDeleted?.selectedId &&
            prevCardIsDeleted?.isDeleted == currCardIsDeleted?.isDeleted
    }
    
    func reactorForDetail(with id: String) -> DetailViewReactor {
        DetailViewReactor(dependencies: self.dependencies, with: id)
    }
}

extension TagSearchViewReactor {
    
    struct TagInfoForCard: Equatable {
        let id: String
        let title: String
    }
    
    enum CleanupFor {
        case push
        case search
        case tagCard
    }
}
