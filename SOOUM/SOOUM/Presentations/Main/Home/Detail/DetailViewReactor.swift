//
//  DetailViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 10/4/24.
//

import ReactorKit


class DetailViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFindForComment(lastId: String)
        case delete
        case block(isBlocked: Bool)
        case updateLike(Bool)
        case updateReport(Bool)
        case willPushToWrite
        case cleanup
    }
    
    enum Mutation {
        case cardType(Bool)
        case detailCard(DetailCardInfo?)
        case commentCards([BaseCardInfo])
        case moreComment([BaseCardInfo])
        case updateIsRefreshing(Bool)
        case updateIsLiked(Bool)
        case updateIsDeleted(Bool)
        case updateReported(Bool)
        case updateIsBlocked(Bool)
        case updateErrors(Int?)
        case willPushToWrite(Bool?)
    }
    
    struct State {
        fileprivate(set) var isFeed: Bool?
        fileprivate(set) var detailCard: DetailCardInfo?
        fileprivate(set) var commentCards: [BaseCardInfo]
        fileprivate(set) var isRefreshing: Bool
        fileprivate(set) var isLiked: Bool
        fileprivate(set) var isDeleted: Bool
        fileprivate(set) var isReported: Bool
        fileprivate(set) var isBlocked: Bool
        fileprivate(set) var hasErrors: Int?
        fileprivate(set) var willPushEnabled: Bool?
    }
    
    var initialState: State = .init(
        isFeed: nil,
        detailCard: nil,
        commentCards: [],
        isRefreshing: false,
        isLiked: false,
        isDeleted: false,
        isReported: false,
        isBlocked: true,
        hasErrors: nil,
        willPushEnabled: nil
    )
    
    private let dependencies: AppDIContainerable
    private let fetchCardDetailUseCase: FetchCardDetailUseCase
    private let deleteCardUseCase: DeleteCardUseCase
    private let updateCardLikeUseCase: UpdateCardLikeUseCase
    private let blockUserUseCase: BlockUserUseCase
    private let locationUseCase: LocationUseCase
    
    let selectedCardId: String
    
    init(dependencies: AppDIContainerable, with selectedCardId: String) {
        self.dependencies = dependencies
        self.fetchCardDetailUseCase = dependencies.rootContainer.resolve(FetchCardDetailUseCase.self)
        self.deleteCardUseCase = dependencies.rootContainer.resolve(DeleteCardUseCase.self)
        self.updateCardLikeUseCase = dependencies.rootContainer.resolve(UpdateCardLikeUseCase.self)
        self.blockUserUseCase = dependencies.rootContainer.resolve(BlockUserUseCase.self)
        self.locationUseCase = dependencies.rootContainer.resolve(LocationUseCase.self)
        
        self.selectedCardId = selectedCardId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            let coordinate = self.locationUseCase.coordinate()
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            
            return .concat([
                self.fetchCardDetailUseCase.detailCard(
                    id: self.selectedCardId,
                    latitude: latitude,
                    longitude: longitude
                )
                .flatMapLatest { detailCardInfo -> Observable<Mutation> in
                    return .concat([
                        .just(.cardType(detailCardInfo.prevCardInfo == nil)),
                        .just(.updateReported(detailCardInfo.isReported)),
                        .just(.detailCard(detailCardInfo))
                    ])
                }
                .catch(self.catchClosure),
                self.commentCards()
            ])
        case .refresh:
            
            return .concat([
                .just(.updateIsRefreshing(true)),
                self.detailCard()
                    .catch(self.catchClosure),
                self.commentCards(),
                .just(.updateIsRefreshing(false))
            ])
        case let .moreFindForComment(lastId):
            
            return self.fetchMoreCommentCards(lastId)
        case .delete:
            
            return self.deleteCardUseCase.delete(cardId: self.selectedCardId)
                .map(Mutation.updateIsDeleted)
        case let .block(isBlocked):
            
            guard let memberId = self.currentState.detailCard?.memberId else { return .empty() }
            
            return self.blockUserUseCase.updateBlocked(userId: memberId, isBlocked: isBlocked)
                .flatMapLatest { isBlockedSuccess -> Observable<Mutation> in
                    /// isBlocked == true 일 때, 차단 요청
                    return isBlockedSuccess ? .just(.updateIsBlocked(isBlocked == false)) : .empty()
                }
                .catch(self.catchClosure)
        case let .updateLike(isLike):
            
            return .concat([
                .just(.updateIsLiked(false)),
                self.updateCardLikeUseCase.updateLike(cardId: self.selectedCardId, isLike: isLike)
                    .filter { $0 }
                    .withUnretained(self)
                    .flatMapLatest { object, _ -> Observable<Mutation> in
                        return .just(.updateIsLiked(true))
                    }
                    .catch(self.catchClosure)
            ])
        case let .updateReport(isReported):
            
            return .just(.updateReported(isReported))
        case .willPushToWrite:
            
            return self.fetchCardDetailUseCase.isDeleted(cardId: self.selectedCardId)
            .flatMapLatest { isDeleted -> Observable<Mutation> in
                return .concat([
                    .just(.willPushToWrite(isDeleted)),
                    .just(.updateIsDeleted(isDeleted))
                ])
            }
        case .cleanup:
            
            return .just(.willPushToWrite(nil))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .cardType(isFeed):
            newState.isFeed = isFeed
        case let .detailCard(detailCard):
            newState.detailCard = detailCard
        case let .commentCards(commentCards):
            newState.commentCards = commentCards
        case let .moreComment(commentCards):
            newState.commentCards += commentCards
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        case let .updateIsLiked(isLiked):
            newState.isLiked = isLiked
        case let .updateIsDeleted(isDeleted):
            newState.isDeleted = isDeleted
        case let .updateReported(isReported):
            newState.isReported = isReported
        case let .updateIsBlocked(isBlocked):
            newState.isBlocked = isBlocked
        case let .updateErrors(hasErrors):
            newState.hasErrors = hasErrors
        case let .willPushToWrite(willPushEnabled):
            newState.willPushEnabled = willPushEnabled
        }
        return newState
    }
    
    func detailCard() -> Observable<Mutation> {
        
        let coordinate = self.locationUseCase.coordinate()
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        return self.fetchCardDetailUseCase.detailCard(
            id: self.selectedCardId,
            latitude: latitude,
            longitude: longitude
        )
        .map(Mutation.detailCard)
    }
    
    func commentCards() -> Observable<Mutation> {
        
        let coordinate = self.locationUseCase.coordinate()
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        return self.fetchCardDetailUseCase.commentCards(
            id: self.selectedCardId,
            lastId: nil,
            latitude: latitude,
            longitude: longitude
        )
        .map(Mutation.commentCards)
    }
    
    func fetchMoreCommentCards(_ lastId: String) -> Observable<Mutation> {
        
        let coordinate = self.locationUseCase.coordinate()
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        return self.fetchCardDetailUseCase.commentCards(
            id: self.selectedCardId,
            lastId: lastId,
            latitude: latitude,
            longitude: longitude
        )
        .map(Mutation.moreComment)
    }
}

extension DetailViewReactor {
    
    func reactorForPush(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor(dependencies: self.dependencies, with: selectedId)
    }
    
    func reactorForReport() -> ReportViewReactor {
        ReportViewReactor(dependencies: self.dependencies, with: self.selectedCardId)
    }
    
    func reactorForWriteCard() -> WriteCardViewReactor {
        WriteCardViewReactor(
            dependencies: self.dependencies,
            type: .comment,
            parentCardId: self.currentState.detailCard?.id
        )
    }
    
    func reactorForTagCollect(with id: String, title: String) -> TagCollectViewReactor {
        TagCollectViewReactor(dependencies: self.dependencies, with: id, title: title, isFavorite: false)
    }
    
    func reactorForProfile(
        type: ProfileViewReactor.EntranceType,
        _ userId: String
    ) -> ProfileViewReactor {
        ProfileViewReactor(dependencies: self.dependencies, type: type, with: userId)
    }
}

extension DetailViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation>) {
        return { error in
            
            let nsError = error as NSError
            // errorCode == 409 일 때, 해당 사용자 중복 차단
            if case 409 = nsError.code {
                return .concat([
                    .just(.updateIsRefreshing(false)),
                    .just(.updateIsBlocked(false))
                ])
            }
            // errorCode == 410 일 때, 이미 삭제된 카드
            if case 410 = nsError.code {
                return .concat([
                    .just(.updateIsRefreshing(false)),
                    .just(.updateIsDeleted(true))
                ])
            }
            
            return .just(.updateIsRefreshing(false))
        }
    }
}
