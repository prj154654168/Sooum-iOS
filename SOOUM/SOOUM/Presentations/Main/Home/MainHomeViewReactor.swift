//
//  MainHomeViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import ReactorKit


class MainHomeViewReactor: Reactor {
    
    enum Action: Equatable {
        case refresh
        case moreFind
        case moreFindWithId(lastId: Double?)
        case homeTabBarItemDidTap(index: Int)
        case coordinate(String, String)
        case distanceFilter(String)
    }
    
    enum Mutation {
        case cards([Card])
        case more([Card])
        case displayedCards([Card])
        case updateIndex(Int)
        case updateCoordinate(String, String)
        case updateDistanceFilter(String)
        case updateIsLoading(Bool)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var cards: [Card]
        var displayedCards: [Card]
        var index: Int
        var coordinate: (String?, String?)
        var distanceFilter: String
        var isLoading: Bool
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        cards: [],
        displayedCards: [],
        index: 0,
        coordinate: (nil, nil),
        distanceFilter: "UNDER_1",
        isLoading: false,
        isProcessing: false
    )
    
    private var countPerLoading: Int = 10
    
    private let networkManager = NetworkManager.shared
    private let locationManager = LocationManager.shared
    
    init() { }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return .concat([
                .just(.updateIsLoading(true)),
                self.refresh(),
                .just(.updateIsLoading(false))
            ])
        case .moreFind:
            let cards = self.currentState.cards
            
            return .concat([
                .just(.updateIsProcessing(true)),
                .just(.displayedCards(cards)),
                .just(.updateIsProcessing(false))
            ])
        case let .moreFindWithId(lastId):
            return .concat([
                .just(.updateIsProcessing(true)),
                self.moreFindWithId(lastId),
                .just(.updateIsProcessing(false))
            ])
        case let .homeTabBarItemDidTap(index):
            return .concat([
                .just(.updateIndex(index)),
                .just(.updateIsLoading(true)),
                .just(.updateIsLoading(false))
            ])
        case let .coordinate(latitude, longitude):
            return .just(.updateCoordinate(latitude, longitude))
        case let .distanceFilter(distanceFilter):
            return .just(.updateDistanceFilter(distanceFilter))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
        case let .cards(cards):
            state.cards = cards
            state.displayedCards = []
            state.displayedCards = self.separate(current: cards)
        case let .more(cards):
            state.cards += cards
            state.displayedCards += self.separate(current: cards)
        case let .displayedCards(cards):
            state.displayedCards += self.separate(current: cards)
        case let .updateIndex(index):
            state.index = index
        case let .updateCoordinate(latitude, longitude):
            state.coordinate = (latitude, longitude)
        case let .updateDistanceFilter(distanceFilter):
            state.distanceFilter = distanceFilter
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        }
        return state
    }
}

extension MainHomeViewReactor {
    
    func refresh() -> Observable<Mutation> {
        
        let selectedIndex = self.currentState.index
        
        let latitude = self.currentState.coordinate.0
        let longitude = self.currentState.coordinate.1
        
        if selectedIndex == 0 {
            let request: CardRequest = .latestCard(
                id: nil,
                latitude: latitude,
                longitude: longitude
            )
            return self.networkManager.request(LatestCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { .cards($0) }
        } else if selectedIndex == 1 {
            let request: CardRequest = .popularCard(latitude: latitude, longitude: longitude)
            return self.networkManager.request(PopularCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { .cards($0) }
        } else {
            let distanceFilter = self.currentState.distanceFilter
            let request: CardRequest = .distancCard(
                id: nil,
                latitude: latitude ?? "",
                longitude: longitude ?? "",
                distanceFilter: distanceFilter
            )
            return self.networkManager.request(DistanceCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { .cards($0) }
        }
    }
    
    func moreFindWithId(_ lastId: Double?) -> Observable<Mutation> {
            
        let selectedIndex = self.currentState.index
        
        let lastId = lastId?.toString ?? ""
        
        let latitude = self.currentState.coordinate.0
        let longitude = self.currentState.coordinate.1
        
        if selectedIndex == 0 {
            let request: CardRequest = .latestCard(
                id: lastId,
                latitude: latitude,
                longitude: longitude
            )
            return self.networkManager.request(LatestCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { .more($0) }
        } else if selectedIndex == 2 {
            let distanceFilter = self.currentState.distanceFilter
            
            let request: CardRequest = .distancCard(
                id: lastId,
                latitude: latitude ?? "",
                longitude: longitude ?? "",
                distanceFilter: distanceFilter
            )
            return self.networkManager.request(DistanceCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { .more($0) }
        }
        
        return .empty()
    }
}

extension MainHomeViewReactor {
    
    func separate(current cards: [Card]) -> [Card] {
        let count = self.currentState.displayedCards.count
        let displayedCards = Array(cards[count..<min(count + self.countPerLoading, cards.count)])
        return displayedCards
    }
}
