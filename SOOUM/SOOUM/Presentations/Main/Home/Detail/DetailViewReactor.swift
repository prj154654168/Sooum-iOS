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
        case block
        case updateLike(Bool)
    }
    
    enum Mutation {
        case detailCard(DetailCard, PrevCard?)
        case commentCards([Card])
        case moreComment([Card])
        case cardSummary(CardSummary)
        case updateIsDeleted(Bool)
        case updateIsBlocked(Bool)
        case updateIsLoading(Bool)
        case updateIsProcessing(Bool)
        case updateError(Bool?)
    }
    
    struct State {
        var detailCard: DetailCard
        var prevCard: PrevCard?
        var commentCards: [Card]
        var cardSummary: CardSummary
        var isDeleted: Bool
        var isBlocked: Bool
        var isLoading: Bool
        var isProcessing: Bool
        var isErrorOccur: Bool?
    }
    
    var initialState: State = .init(
        detailCard: .init(),
        prevCard: nil,
        commentCards: [],
        cardSummary: .init(),
        isDeleted: false,
        isBlocked: false,
        isLoading: false,
        isProcessing: false,
        isErrorOccur: nil
    )
    
    private let networkManager = NetworkManager.shared
    private let locationManager = LocationManager.shared
    
    let entranceType: EntranceType
    let selectedCardId: String
    var parentPungTime: Date?
    
    init(
        type entranceType: EntranceType = .navi,
        _ selectedCardId: String,
        hasPungTime parentPungTime: Date? = nil
    ) {
        self.entranceType = entranceType
        self.selectedCardId = selectedCardId
        self.parentPungTime = parentPungTime
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            return .concat([
                .just(.updateIsProcessing(true)),
                
                Observable.zip(
                    self.fetchDetailCard(),
                    self.fetchCommentCards(),
                    self.fetchCardSummary()
                )
                .flatMap { detailCardMutation, commentCardsMutation, cardSummaryMutation in
                    Observable.from([detailCardMutation, commentCardsMutation, cardSummaryMutation])
                }
                .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                
                .just(.updateIsProcessing(false))
            ])
        case .refresh:
            return .concat([
                .just(.updateIsLoading(true)),
                
                Observable.zip(
                    self.fetchDetailCard(),
                    self.fetchCommentCards(),
                    self.fetchCardSummary()
                )
                .flatMap { detailCardMutation, commentCardsMutation, cardSummaryMutation in
                    Observable.from([detailCardMutation, commentCardsMutation, cardSummaryMutation])
                }
                .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                
                .just(.updateIsLoading(false))
            ])
        case let .moreFindForComment(lastId):
            return .concat([
                .just(.updateIsProcessing(true)),
                self.fetchMoreCommentCards(lastId)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsProcessing(false))
            ])
        case .delete:
            let request: CardRequest = .deleteCard(id: self.selectedCardId)
            return self.networkManager.request(Status.self, request: request)
                .map { _ in .updateIsDeleted(true) }
        case .block:
            let request: ReportRequest = .blockMember(id: self.currentState.detailCard.member.id)
            return self.networkManager.request(Status.self, request: request)
                .map { .updateIsBlocked($0.httpCode == 201) }
        case let .updateLike(isLike):
            let request: CardRequest = .updateLike(id: self.selectedCardId, isLike: isLike)
            return .concat([
                self.networkManager.request(Status.self, request: request)
                    .filter { $0.httpCode != 400 }
                    .withUnretained(self)
                    .flatMapLatest { object, _ in object.fetchCardSummary() }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .detailCard(detailCard, prevCard):
            state.detailCard = detailCard
            state.prevCard = prevCard
        case let .commentCards(commentCards):
            state.commentCards = commentCards
        case let .moreComment(commentCards):
            state.commentCards += commentCards
        case let .cardSummary(cardSummary):
            state.cardSummary = cardSummary
        case let .updateIsDeleted(isDeleted):
            state.isDeleted = isDeleted
        case let .updateIsBlocked(isBlocked):
            state.isBlocked = isBlocked
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        case let .updateError(isErrorOccur):
            state.isErrorOccur = isErrorOccur
        }
        return state
    }
    
    func fetchDetailCard() -> Observable<Mutation> {
        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        let requset: CardRequest = .detailCard(
            id: self.selectedCardId,
            latitude: latitude,
            longitude: longitude
        )
        
        return self.networkManager.request(DetailCardResponse.self, request: requset)
            .flatMapLatest { response -> Observable<Mutation> in
                let detailCard = response.detailCard
                let prevCard = response.prevCard
                
                return .just(.detailCard(detailCard, prevCard))
            }
            .catch(self.catchClosure)
    }
    
    func fetchCommentCards() -> Observable<Mutation> {
        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        let requset: CardRequest = .commentCard(
            id: self.selectedCardId,
            lastId: nil,
            latitude: latitude,
            longitude: longitude
        )
        return self.networkManager.request(CommentCardResponse.self, request: requset)
            .map(\.embedded.commentCards)
            .map(Mutation.commentCards)
            .catch(self.catchClosure)
    }
    
    func fetchMoreCommentCards(_ lastId: String) -> Observable<Mutation> {
        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        let request: CardRequest = .commentCard(
            id: self.selectedCardId,
            lastId: lastId,
            latitude: latitude,
            longitude: longitude
        )
        return self.networkManager.request(CommentCardResponse.self, request: request)
            .map(\.embedded.commentCards)
            .map(Mutation.moreComment)
            .catch(self.catchClosure)
    }
    
    func fetchCardSummary() -> Observable<Mutation> {
        let requset: CardRequest = .cardSummary(id: self.selectedCardId)
        return self.networkManager.request(CardSummaryResponse.self, request: requset)
            .map(\.cardSummary)
            .map(Mutation.cardSummary)
            .catch(self.catchClosure)
    }
}

extension DetailViewReactor {
    
    func reactorForMainTabBar() -> MainTabBarReactor {
        MainTabBarReactor(pushInfo: nil)
    }
    
    func reactorForMainHome() -> MainHomeTabBarReactor {
        MainHomeTabBarReactor()
    }
    
    func reactorForPush(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor(
            selectedId,
            hasPungTime: self.parentPungTime ?? self.currentState.detailCard.storyExpirationTime
        )
    }
    
    func reactorForReport() -> ReportViewReactor {
        ReportViewReactor(self.selectedCardId)
    }
    
    func reactorForWriteCard() -> WriteCardViewReactor {
        WriteCardViewReactor(
            type: .comment,
            parentCardId: self.selectedCardId,
            parentPungTime: self.currentState.detailCard.storyExpirationTime ?? self.parentPungTime
        )
    }
    
    func reactorForProfile(
        type: ProfileViewReactor.EntranceType,
        _ memberId: String
    ) -> ProfileViewReactor {
        ProfileViewReactor.init(type: type, memberId: memberId)
    }
    
    func reactorForNoti() -> NotificationTabBarReactor {
        NotificationTabBarReactor()
    }
}

extension DetailViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { error in
            
            let nsError = error as NSError
            let endProcessing = Observable<Mutation>.concat([
                .just(.updateIsProcessing(false)),
                .just(.updateIsLoading(false))
            ])
            
            if nsError.code == 400 {
                return .concat([
                    .just(.updateError(true)),
                    endProcessing
                ])
            } else {
                return endProcessing
            }
        }
    }
}
