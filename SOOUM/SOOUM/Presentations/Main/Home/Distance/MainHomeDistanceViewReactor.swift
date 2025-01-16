//
//  MainHomeDistanceViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import ReactorKit


class MainHomeDistanceViewReactor: Reactor {
    
    // isUpdate == true 일 때, more
    typealias CardsWithUpdate = (cards: [Card], isUpdate: Bool)
    
    enum Action: Equatable {
        case landing(fromToParent: Bool)
        case refresh
        case moreFind(lastId: String)
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
        var displayedCardsWithUpdate: CardsWithUpdate?
        var distanceFilter: String
        var isLoading: Bool
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        displayedCardsWithUpdate: nil,
        distanceFilter: "UNDER_1",
        isLoading: false,
        isProcessing: false
    )
    
    let provider: ManagerProviderType
    
    let simpleCache = SimpleCache.shared
    
    // TODO: 페이징
    // private let countPerLoading: Int = 10
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .landing(fromToParent):
            
            // Navigation pop 으로 인한 표시이거나 (최우선),
            // 캐시가 존재하지 않으면 서버 요청
            if fromToParent {
                
                // Pop 으로 인한 viewWillAppear 일 때, 딜레이 및 로딩 제거
                return self.refresh(self.currentState.distanceFilter)
            } else {
                
                if self.simpleCache.isEmpty(type: .distance) {
                    
                    // 캐시가 존재하지 않으면 서버 요청
                    return .concat([
                        .just(.updateIsProcessing(true)),
                        self.refresh(self.currentState.distanceFilter)
                            .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                        .just(.updateIsProcessing(false))
                    ])
                } else {
                    
                    // 캐시가 존재하면 캐싱된 데이터 사용
                    let cachedCards = self.simpleCache.loadMainHomeCards(type: .distance) ?? []
                    
                    return .just(.cards((cards: cachedCards, isUpdate: false)))
                }
            }
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
            state.displayedCardsWithUpdate?.isUpdate = displayedCardsWithUpdate.isUpdate
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
            .withUnretained(self)
            .map { object, cards in
                
                // 서버 응답 캐싱
                object.simpleCache.saveMainHomeCards(type: .distance, datas: cards)
                
                return .cards((cards: cards, isUpdate: false))
            }
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
            .withUnretained(self)
            .map { object, cards in
                
                let cachedCards = object.simpleCache.loadMainHomeCards(type: .distance) ?? []
                var newCards = cachedCards
                newCards += cards
                
                object.simpleCache.saveMainHomeCards(type: .distance, datas: newCards)
                return .more((cards: cards, isUpdate: true))
            }
            .catch(self.catchClosure)
    }
}

extension MainHomeDistanceViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.cards((cards: [], isUpdate: false))),
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
            prevCardsWithUpdate.isUpdate == currCardsWithUpdate.isUpdate
    }
}
