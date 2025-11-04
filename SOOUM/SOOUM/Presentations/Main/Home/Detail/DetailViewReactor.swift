//
//  DetailViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 10/4/24.
//

import ReactorKit


class DetailViewReactor: Reactor {
    
    enum EntranceType {
        case push
        case navi
    }
    
    enum DetailType {
        case feed
        case comment
    }
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFindForComment(lastId: String)
        case delete
        case block(isBlocked: Bool)
        case updateLike(Bool)
    }
    
    enum Mutation {
        case detailCard(DetailCardInfo?)
        case commentCards([BaseCardInfo])
        case moreComment([BaseCardInfo])
        case updateIsRefreshing(Bool)
        case updateIsLiked(Bool)
        case updateIsBlocked(Bool)
        case updateIsDeleted(Bool)
        case updateErrors(Int?)
    }
    
    struct State {
        fileprivate(set) var detailCard: DetailCardInfo?
        fileprivate(set) var commentCards: [BaseCardInfo]
        fileprivate(set) var isRefreshing: Bool
        fileprivate(set) var isLiked: Bool
        fileprivate(set) var isBlocked: Bool
        fileprivate(set) var isDeleted: Bool
        fileprivate(set) var hasErrors: Int?
    }
    
    var initialState: State = .init(
        detailCard: nil,
        commentCards: [],
        isRefreshing: false,
        isLiked: false,
        isBlocked: false,
        isDeleted: false,
        hasErrors: nil
    )
    
    private let dependencies: AppDIContainerable
    private let cardUseCase: CardUseCase
    
    private let locationManager: LocationManagerDelegate
    
    let detailType: DetailType
    let entranceType: EntranceType
    let selectedCardId: String
    
    init(
        dependencies: AppDIContainerable,
        _ detailType: DetailType,
        type entranceType: EntranceType = .navi,
        with selectedCardId: String
    ) {
        self.dependencies = dependencies
        self.cardUseCase = dependencies.rootContainer.resolve(CardUseCase.self)
        
        self.locationManager = dependencies.rootContainer.resolve(ManagerProviderType.self).locationManager
        
        self.detailType = detailType
        self.entranceType = entranceType
        self.selectedCardId = selectedCardId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                self.detailCard(),
                self.commentCards()
            ])
        case .refresh:
            
            return .concat([
                .just(.updateIsRefreshing(true)),
                self.detailCard(),
                self.commentCards(),
                .just(.updateIsRefreshing(false))
            ])
        case let .moreFindForComment(lastId):
            
            return self.fetchMoreCommentCards(lastId)
        case .delete:
            
            return self.cardUseCase.deleteCard(id: self.selectedCardId)
                .map(Mutation.updateIsDeleted)
        case let .block(isBlocked):
            
            guard let memberId = self.currentState.detailCard?.memberId else { return .empty() }
            
            return self.cardUseCase.updateBlocked(id: memberId, isBlocked: isBlocked)
                .map(Mutation.updateIsBlocked)
        case let .updateLike(isLike):
            
            return .concat([
                .just(.updateIsLiked(false)),
                self.cardUseCase.updateLike(id: self.selectedCardId, isLike: isLike)
                    .filter { $0 }
                    .withUnretained(self)
                    .flatMapLatest { object, _ -> Observable<Mutation> in
                        return .just(.updateIsLiked(true))
                    }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
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
        case let .updateIsBlocked(isBlocked):
            newState.isBlocked = isBlocked
        case let .updateIsDeleted(isDeleted):
            newState.isDeleted = isDeleted
        case let .updateErrors(hasErrors):
            newState.hasErrors = hasErrors
        }
        return newState
    }
    
    func detailCard() -> Observable<Mutation> {
        
        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        return self.cardUseCase.detailCard(
            id: self.selectedCardId,
            latitude: latitude,
            longitude: longitude
        )
        .map(Mutation.detailCard)
    }
    
    func commentCards() -> Observable<Mutation> {
        
        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        return self.cardUseCase.commentCard(
            id: self.selectedCardId,
            lastId: nil,
            latitude: latitude,
            longitude: longitude
        )
        .map(Mutation.commentCards)
    }
    
    func fetchMoreCommentCards(_ lastId: String) -> Observable<Mutation> {
        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        return self.cardUseCase.commentCard(
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
        DetailViewReactor(dependencies: self.dependencies, .comment, type: .push, with: selectedId)
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
    
    // func reactorForTagDetail(_ tagID: String) -> TagDetailViewrReactor {
    //     TagDetailViewrReactor(provider: self.provider, tagID: tagID)
    // }
    
    // func reactorForProfile(
    //     type: ProfileViewReactor.EntranceType,
    //     _ memberId: String
    // ) -> ProfileViewReactor {
    //     ProfileViewReactor(provider: self.provider, type: type, memberId: memberId)
    // }
    
    // func reactorForNoti() -> NotificationTabBarReactor {
    //     NotificationTabBarReactor(provider: self.provider)
    // }
}

extension DetailViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { error in
            
            let nsError = error as NSError
            return .concat([
                .just(.updateIsBlocked(false)),
                .just(.updateIsDeleted(false)),
                .just(.updateIsRefreshing(false)),
                .just(.updateErrors(nsError.code))
            ])
        }
    }
}
