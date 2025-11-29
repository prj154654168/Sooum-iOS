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
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFindForComment(lastId: String)
        case delete
        case block(isBlocked: Bool)
        case updateLike(Bool)
        case updateReport(Bool)
        case willPushToWrite
        case resetPushState
    }
    
    enum Mutation {
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
    private let cardUseCase: CardUseCase
    private let userUseCase: UserUseCase
    private let settingsUseCase: SettingsUseCase
    
    let entranceCardType: EntranceCardType
    let entranceType: EntranceType
    let selectedCardId: String
    
    init(
        dependencies: AppDIContainerable,
        _ entranceCardType: EntranceCardType,
        type entranceType: EntranceType = .navi,
        with selectedCardId: String
    ) {
        self.dependencies = dependencies
        self.cardUseCase = dependencies.rootContainer.resolve(CardUseCase.self)
        self.userUseCase = dependencies.rootContainer.resolve(UserUseCase.self)
        self.settingsUseCase = dependencies.rootContainer.resolve(SettingsUseCase.self)
        
        self.entranceCardType = entranceCardType
        self.entranceType = entranceType
        self.selectedCardId = selectedCardId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                self.detailCard()
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
            
            return self.cardUseCase.deleteCard(id: self.selectedCardId)
                .map(Mutation.updateIsDeleted)
        case let .block(isBlocked):
            
            guard let memberId = self.currentState.detailCard?.memberId else { return .empty() }
            
            return self.userUseCase.updateBlocked(id: memberId, isBlocked: isBlocked)
                .flatMapLatest { isBlockedSuccess -> Observable<Mutation> in
                    /// isBlocked == true 일 때, 차단 요청
                    return isBlockedSuccess ? .just(.updateIsBlocked(isBlocked == false)) : .empty()
                }
                .catch(self.catchClosure)
        case let .updateLike(isLike):
            
            return .concat([
                .just(.updateIsLiked(false)),
                self.cardUseCase.updateLike(id: self.selectedCardId, isLike: isLike)
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
            
            return self.detailCard()
                .map { _ in .willPushToWrite(true) }
                .catchAndReturn(.willPushToWrite(false))
        case .resetPushState:
            
            return .just(.willPushToWrite(nil))
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
        
        let coordinate = self.settingsUseCase.coordinate()
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        return self.cardUseCase.detailCard(
            id: self.selectedCardId,
            latitude: latitude,
            longitude: longitude
        )
        .map(Mutation.detailCard)
    }
    
    func commentCards() -> Observable<Mutation> {
        
        let coordinate = self.settingsUseCase.coordinate()
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        return self.cardUseCase.commentCard(
            id: self.selectedCardId,
            lastId: nil,
            latitude: latitude,
            longitude: longitude
        )
        .map(Mutation.commentCards)
    }
    
    func fetchMoreCommentCards(_ lastId: String) -> Observable<Mutation> {
        
        let coordinate = self.settingsUseCase.coordinate()
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
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
