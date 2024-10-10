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
        case coordinate(String, String)
    }
    
    enum Mutation {
        case detailCard(DetailCard)
        case commentCards([CommentCard])
        case cardSummary(CardSummary)
        case updateCoordinate(String, String)
        case updateIsLoading(Bool)
    }
    
    struct State {
        var detailCard: DetailCard
        var commentCards: [CommentCard]
        var cardSummary: CardSummary
        var coordinate: (String?, String?)
        var isLoading: Bool
    }
    
    var initialState: State = .init(
        detailCard: .init(),
        commentCards: [],
        cardSummary: .init(),
        coordinate: (nil, nil),
        isLoading: false
    )
    
    private let networkManager = NetworkManager.shared
    private let locationManager = LocationManager.shared
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
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
                ).flatMap { detailCardMutation, commentCardsMutation, cardSummaryMutation in
                    Observable.from([detailCardMutation, commentCardsMutation, cardSummaryMutation])
                },
                .just(.updateIsLoading(false))
            ])
        case let .coordinate(latitude, longitude):
            return .just(.updateCoordinate(latitude, longitude))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .detailCard(detailCard):
            state.detailCard = detailCard
        case let .commentCards(commentCards):
            state.commentCards = commentCards
        case let .cardSummary(cardSummary):
            state.cardSummary = cardSummary
        case let .updateCoordinate(latitude, longitude):
            state.coordinate = (latitude, longitude)
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        }
        return state
    }
    
    func fetchDetailCard() -> Observable<Mutation> {
        let latitude = self.currentState.coordinate.0
        let longitude = self.currentState.coordinate.1
        
        let requset: CardRequest = .detailCard(
            id: self.id,
            latitude: latitude,
            longitude: longitude
        )
        return self.networkManager.request(DetailCardResponse.self, request: requset)
            .map(\.detailCard)
            .map { .detailCard($0) }
    }
    
    func fetchCommentCards() -> Observable<Mutation> {
        let latitude = self.currentState.coordinate.0
        let longitude = self.currentState.coordinate.1
        
        let requset: CardRequest = .detailCard(
            id: self.id,
            latitude: latitude,
            longitude: longitude
        )
        return self.networkManager.request(CommentCardResponse.self, request: requset)
            .map(\.embedded.commentCardsInfoList)
            .map { .commentCards($0) }
    }
    
    func fetchCardSummary() -> Observable<Mutation> {
        let requset: CardRequest = .cardSummary(id: self.id)
        return self.networkManager.request(CardSummaryResponse.self, request: requset)
            .map(\.cardSummary)
            .map { .cardSummary($0) }
    }
}
