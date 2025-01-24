//
//  MainHomePopularViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import ReactorKit


class MainHomePopularViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case refresh
    }
    
    enum Mutation {
        case cards([Card])
        case updateIsLoading(Bool)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        fileprivate(set) var displayedCards: [Card]?
        fileprivate(set) var isLoading: Bool
        fileprivate(set) var isProcessing: Bool
        
        var isDisplayedCardsEmpty: Bool {
            return self.displayedCards?.isEmpty ?? true
        }
        var displayedCardsCount: Int {
            return self.isDisplayedCardsEmpty ? 1 : (self.displayedCards?.count ?? 1)
        }
    }
    
    var initialState: State = .init(
        displayedCards: nil,
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
                self.refresh()
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsProcessing(false))
            ])
        case .refresh:
            return .concat([
                .just(.updateIsLoading(true)),
                self.refresh()
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
        case let .cards(displayedCards):
            state.displayedCards = displayedCards
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        }
        return state
    }
}

extension MainHomePopularViewReactor {
    
    func refresh() -> Observable<Mutation> {
        
        let latitude = self.provider.locationManager.coordinate.latitude
        let longitude = self.provider.locationManager.coordinate.longitude
        
        let request: CardRequest = .popularCard(latitude: latitude, longitude: longitude)
        return self.provider.networkManager.request(PopularCardResponse.self, request: request)
            .map(\.embedded.cards)
            .map(Mutation.cards)
            .catch(self.catchClosure)
    }
}

extension MainHomePopularViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.cards([])),
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
}
