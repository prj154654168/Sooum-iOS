//
//  MainHomeDistanceViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import ReactorKit


class MainHomeDistanceViewReactor: Reactor {
    
    // hasMoreUpdate == true 일 때, more
    typealias CardsWithUpdate = (cards: [Card], hasMoreUpdate: Bool)
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFind(String)
        case distanceFilter(String)
    }
    
    enum Mutation {
        case cards(CardsWithUpdate)
        case more(CardsWithUpdate)
        case updateDistanceFilter(String)
        case updateIsLoading(Bool)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        fileprivate(set) var displayedCardsWithUpdate: CardsWithUpdate?
        fileprivate(set) var distanceFilter: String
        fileprivate(set) var isLoading: Bool
        fileprivate(set) var isProcessing: Bool
        
        var displayedCards: [Card] {
            return self.displayedCardsWithUpdate?.cards ?? []
        }
        var isDisplayedCardsEmpty: Bool {
            return self.displayedCards.isEmpty
        }
        var displayedCardsCount: Int {
            return self.isDisplayedCardsEmpty ? 1 : self.displayedCards.count
        }
    }
    
    var initialState: State = .init(
        displayedCardsWithUpdate: nil,
        distanceFilter: "UNDER_1",
        isLoading: false,
        isProcessing: false
    )
    
    let provider: ManagerProviderType
    
    // TODO: 페이징
    // private let countPerLoading: Int = 10
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.refresh(self.currentState.distanceFilter)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsProcessing(false))
            ])
        case .refresh:
            
            return .concat([
                .just(.updateIsLoading(true)),
                self.refresh(self.currentState.distanceFilter)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsLoading(false))
            ])
        case let .moreFind(lastId):
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.moreFind(lastId),
                .just(.updateIsProcessing(false))
            ])
        case let .distanceFilter(distanceFilter):
            
            return .concat([
                .just(.updateIsProcessing(true)),
                .just(.updateDistanceFilter(distanceFilter)),
                self.refresh(distanceFilter)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsProcessing(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
        case let .cards(displayedCardsWithUpdate):
            state.displayedCardsWithUpdate = displayedCardsWithUpdate
        case let .more(displayedCardsWithUpdate):
            state.displayedCardsWithUpdate?.cards += displayedCardsWithUpdate.cards
            state.displayedCardsWithUpdate?.hasMoreUpdate = displayedCardsWithUpdate.hasMoreUpdate
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

extension MainHomeDistanceViewReactor {
    
    func refresh(_ distanceFilter: String) -> Observable<Mutation> {
        
        let latitude = self.provider.locationManager.coordinate.latitude
        let longitude = self.provider.locationManager.coordinate.longitude
        
        let request: CardRequest = .distancCard(
            lastId: nil,
            latitude: latitude,
            longitude: longitude,
            distanceFilter: distanceFilter
        )
        return self.provider.networkManager.request(DistanceCardResponse.self, request: request)
            .map(\.embedded.cards)
            .map { Mutation.cards((cards: $0, hasMoreUpdate: false)) }
            .catch(self.catchClosure)
    }
    
    func moreFind(_ lastId: String) -> Observable<Mutation> {
        
        let latitude = self.provider.locationManager.coordinate.latitude
        let longitude = self.provider.locationManager.coordinate.longitude
        
        let distanceFilter = self.currentState.distanceFilter
        
        let request: CardRequest = .distancCard(
            lastId: lastId,
            latitude: latitude,
            longitude: longitude,
            distanceFilter: distanceFilter
        )
        return self.provider.networkManager.request(DistanceCardResponse.self, request: request)
            .map(\.embedded.cards)
            .map { Mutation.more((cards: $0, hasMoreUpdate: true)) }
            .catch(self.catchClosure)
    }
}

extension MainHomeDistanceViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.cards((cards: [], hasMoreUpdate: false))),
                .just(.updateIsProcessing(false)),
                .just(.updateIsLoading(false))
            ])
        }
    }
    
    // TODO: 페이징
    // func separate(displayed displayedCards: [Card], current cards: [Card]) -> [Card] {
    //     let count = displayedCards.count
    //     let displayedCards = Array(cards[count..<min(count + self.countPerLoading, cards.count)])
    //     return displayedCards
    // }
  
    func canUpdateCells(
        prev prevCardsWithUpdate: CardsWithUpdate,
        curr currCardsWithUpdate: CardsWithUpdate
    ) -> Bool {
        return prevCardsWithUpdate.cards == currCardsWithUpdate.cards &&
            prevCardsWithUpdate.hasMoreUpdate == currCardsWithUpdate.hasMoreUpdate
    }
}
