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
        case delete
        case updateLike(Bool)
    }
    
    enum Mutation {
        case detailCard(DetailCard, PrevCard)
        case commentCards([Card])
        case cardSummary(CardSummary)
        case updateIsDeleted(Bool)
        case updateIsLoading(Bool)
        case updateIsProcessing(Bool)
        case updateError(String?)
    }
    
    struct State {
        var detailCard: DetailCard
        var prevCard: PrevCard
        var commentCards: [Card]
        var cardSummary: CardSummary
        var isDeleted: Bool
        var isLoading: Bool
        var isProcessing: Bool
        var errorMessage: String?
    }
    
    var initialState: State = .init(
        detailCard: .init(),
        prevCard: .init(),
        commentCards: [],
        cardSummary: .init(),
        isDeleted: false,
        isLoading: false,
        isProcessing: false,
        errorMessage: nil
    )
    
    private let networkManager = NetworkManager.shared
    private let locationManager = LocationManager.shared
    
    var selectedCardIds: [String]
    
    /// id가 nil이면 pop, nil이 아니면 push
    /// selectedCardIds.count == 1 이면 isFrom == .mainHome, 아니면 isFrom == .detailComment
    init(_ selectedCardIds: [String]) {
        self.selectedCardIds = selectedCardIds
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
        case .delete:
            guard let id = self.selectedCardIds.last else { return .empty() }
            let request: CardRequest = .deleteCard(id: id)
            return self.networkManager.request(Status.self, request: request)
                .map { _ in .updateIsDeleted(true) }
        case let .updateLike(isLike):
            guard let id = self.selectedCardIds.last else { return .empty() }
            let request: CardRequest = .updateLike(id: id, isLike: isLike)
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
        case let .cardSummary(cardSummary):
            state.cardSummary = cardSummary
        case let .updateIsDeleted(isDeleted):
            state.isDeleted = isDeleted
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        case let .updateError(errorMessage):
            state.errorMessage = errorMessage
        }
        return state
    }
    
    func fetchDetailCard() -> Observable<Mutation> {
        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        let requset: CardRequest = .detailCard(
            id: self.selectedCardIds.last ?? "",
            latitude: latitude,
            longitude: longitude
        )
        
        switch self.selectedCardIds.count {
        case ...1:
            return self.networkManager.request(DetailCardResponse.self, request: requset)
                .map(\.detailCard)
                .map { .detailCard($0, .init()) }
                .catch { _ in .just(.updateError("에러발생 비상~~")) }
        case 2...:
            return self.networkManager.request(DetailCardByCommentResponse.self, request: requset)
                .map { ($0.detailCard, $0.prevCard) }
                .map { .detailCard($0, $1) }
                .catch { _ in .just(.updateError("에러발생 비상~~")) }
        default:
            return .just(.updateError("selectedCardIds.count index error"))
        }
    }
    
    func fetchCommentCards() -> Observable<Mutation> {
        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        let requset: CardRequest = .commentCard(
            id: self.selectedCardIds.last ?? "",
            latitude: latitude,
            longitude: longitude
        )
        return self.networkManager.request(CommentCardResponse.self, request: requset)
            .map(\.embedded.commentCards)
            .map { .commentCards($0) }
            .catch { _ in .just(.updateError("에러발생 비상~~")) }
    }
    
    func fetchCardSummary() -> Observable<Mutation> {
        let requset: CardRequest = .cardSummary(id: self.selectedCardIds.last ?? "")
        return self.networkManager.request(CardSummaryResponse.self, request: requset)
            .map(\.cardSummary)
            .map { .cardSummary($0) }
            .catch { _ in .just(.updateError("에러발생 비상~~")) }
    }
}

extension DetailViewReactor {
    
    func reactorForMainHome() -> MainHomeViewReactor {
        return MainHomeViewReactor()
    }
    
    func reactorForPush(_ selectedId: String) -> DetailViewReactor {
        self.selectedCardIds.append(selectedId)
        return DetailViewReactor(self.selectedCardIds)
    }
    
    func reactorForPop() -> DetailViewReactor {
        return DetailViewReactor(self.selectedCardIds.dropLast())
    }
    
    func reactorForReport(_ id: String) -> ReportViewReactor {
        return ReportViewReactor(id)
    }
}
