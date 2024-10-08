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
        case moreFind(lastId: String?, selectedIndex: Int)
        case homeTabBarItemDidTap(index: Int)
        case coordinate(String, String)
        case distanceFilter(String)
    }
    
    enum Mutation {
        case cards([Card])
        case more([Card])
        case updateSelectedIndex(Int)
        case updateCoordinate(String, String)
        case updateDistanceFilter(String)
        case updateIsLoading(Bool)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var cards: [Card]
        var selectedIndex: Int
        var coordinate: (String?, String?)
        var distanceFilter: String
        var isLoading: Bool
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        cards: [],
        selectedIndex: 0,
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
        case let .moreFind(lastId, selectedIndex):
            return .concat([
                .just(.updateIsProcessing(true)),
                self.moreFind(lastId, index: selectedIndex),
                .just(.updateIsProcessing(false))
            ])
        case let .homeTabBarItemDidTap(index):
            return .concat([
                .just(.updateIsLoading(true)),
                .just(.updateSelectedIndex(index)),
                self.refresh(index),
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
        case let .more(cards):
            state.cards += cards
        case let .updateSelectedIndex(selectedIndex):
            state.selectedIndex = selectedIndex
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
    
    func refresh(_ selectedIndex: Int = 0) -> Observable<Mutation> {
        
        let latitude = self.currentState.coordinate.0
        let longitude = self.currentState.coordinate.1
        
        let distanceFilter = self.currentState.distanceFilter
        
        var request: CardRequest {
            switch selectedIndex {
            case 1:
                return .popularCard(latitude: latitude, longitude: longitude)
            case 2:
                return .distancCard(
                    id: nil,
                    latitude: latitude ?? "",
                    longitude: longitude ?? "",
                    distanceFilter: distanceFilter
                )
            default:
                return .latestCard(id: nil, latitude: latitude, longitude: longitude)
            }
        }
        
        if selectedIndex == 0 {
            return self.networkManager.request(LatestCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { .cards($0) }
        } else if selectedIndex == 1 {
            return self.networkManager.request(PopularCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { .cards($0) }
        } else {
            return self.networkManager.request(DistanceCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { .cards($0) }
        }
    }
    
    func moreFind(_ lastId: String?, index selectedIndex: Int) -> Observable<Mutation> {
        
        if selectedIndex == 1 { return .empty() }
        
        let lastId = lastId ?? ""
        
        let latitude = self.currentState.coordinate.0
        let longitude = self.currentState.coordinate.1
        
        let distanceFilter = self.currentState.distanceFilter
        
        var request: CardRequest {
            switch selectedIndex {
            case 2:
                return .distancCard(
                    id: lastId,
                    latitude: latitude ?? "",
                    longitude: longitude ?? "",
                    distanceFilter: distanceFilter
                )
            default:
                return .latestCard(id: lastId, latitude: latitude, longitude: longitude)
            }
        }
        
        if selectedIndex == 0 {
            return self.networkManager.request(LatestCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { .more($0) }
        } else {
            return self.networkManager.request(DistanceCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { .more($0) }
        }
    }
}

/// Hand oveer reactor
extension MainHomeViewReactor {
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor(selectedId)
    }
}
