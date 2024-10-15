//
//  DetailViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 10/4/24.
//

import ReactorKit


class DetailViewReactor: Reactor {
    
    enum Action: Equatable {
        case refresh
    }
    
    enum Mutation {
        case detailCard(DetailCard, PrevCard)
        case commentCards([Card])
        case cardSummary(CardSummary)
        case updateIsLoading(Bool)
    }
    
    struct State {
        var detailCard: DetailCard
        var prevCard: PrevCard
        var commentCards: [Card]
        var cardSummary: CardSummary
        var isLoading: Bool
    }
    
    var initialState: State = .init(
        detailCard: .init(),
        prevCard: .init(),
        commentCards: [],
        cardSummary: .init(),
        isLoading: false
    )
    
    private let networkManager = NetworkManager.shared
    private let locationManager = LocationManager.shared
    
    private var selectedCardIds: [String]
    
    /// id가 nil이면 pop, nil이 아니면 push
    /// selectedCardIds.count == 1 이면 isFrom == .mainHome, 아니면 isFrom == .detailComment
    init(_ selectedCardIds: [String]) {
        self.selectedCardIds = selectedCardIds
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
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
                },
                .just(.updateIsLoading(false))
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
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
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
        
        if self.selectedCardIds.count < 2 {
            return self.networkManager.request(DetailCardResponse.self, request: requset)
                .map(\.detailCard)
                .map { .detailCard($0, .init()) }
        } else {
            return self.networkManager.request(DetailCardByCommentResponse.self, request: requset)
                .map { ($0.detailCard, $0.prevCard) }
                .map { .detailCard($0, $1) }
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
    }
    
    func fetchCardSummary() -> Observable<Mutation> {
        let requset: CardRequest = .cardSummary(id: self.selectedCardIds.last ?? "")
        return self.networkManager.request(CardSummaryResponse.self, request: requset)
            .map(\.cardSummary)
            .map { .cardSummary($0) }
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
}
