//
//  MainHomeLatestViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import ReactorKit


class MainHomeLatestViewReactor: Reactor {
    
    // isUpdate == true 일 때, more
    typealias CardsWithUpdate = (cards: [Card], isUpdate: Bool)
    
    enum Action: Equatable {
        case landing(fromToParent: Bool)
        case refresh
        case moreFind(lastId: String)
    }
    
    enum Mutation {
        case cards(CardsWithUpdate)
        case more(CardsWithUpdate)
        case updateIsLoading(Bool)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var displayedCardsWithUpdate: CardsWithUpdate?
        var isLoading: Bool
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        displayedCardsWithUpdate: nil,
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
                return self.refresh()
            } else {
                
                if self.simpleCache.isEmpty(type: .latest) {
                    
                    // 캐시가 존재하지 않을 떄
                    return .concat([
                        .just(.updateIsProcessing(true)),
                        self.refresh()
                            .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                        .just(.updateIsProcessing(false))
                    ])
                } else {
                    
                    // 캐시가 존재하면 캐싱된 데이터 사용
                    let cachedCards = self.simpleCache.loadMainHomeCards(type: .latest) ?? []
                    
                    return .just(.cards((cards: cachedCards, isUpdate: false)))
                }
            }
        case .refresh:
            return .concat([
                .just(.updateIsLoading(true)),
                self.refresh()
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsLoading(false))
            ])
        case let .moreFind(lastId):
            return .concat([
                .just(.updateIsProcessing(true)),
                self.moreFind(lastId)
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
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        }
        return state
    }
}

extension MainHomeLatestViewReactor {
    
    func refresh() -> Observable<Mutation> {
        
        let latitude = self.provider.locationManager.coordinate.latitude
        let longitude = self.provider.locationManager.coordinate.longitude
        
        let request: CardRequest = .latestCard(lastId: nil, latitude: latitude, longitude: longitude)
        
        return self.provider.networkManager.request(LatestCardResponse.self, request: request)
            .map(\.embedded.cards)
            .withUnretained(self)
            .map { object, cards in
                
                // 서버 응답 캐싱
                object.simpleCache.saveMainHomeCards(type: .latest, datas: cards)
                
                return .cards((cards: cards, isUpdate: false))
            }
            .catch(self.catchClosure)
    }
    
    func moreFind(_ lastId: String) -> Observable<Mutation> {
        
        let latitude = self.provider.locationManager.coordinate.latitude
        let longitude = self.provider.locationManager.coordinate.longitude
        
        let request: CardRequest = .latestCard(lastId: lastId, latitude: latitude, longitude: longitude)
        
        return self.provider.networkManager.request(LatestCardResponse.self, request: request)
            .map(\.embedded.cards)
            .withUnretained(self)
            .map { object, cards in
                
                let cachedCards = object.simpleCache.loadMainHomeCards(type: .latest) ?? []
                var newCards = cachedCards
                newCards += cards
                
                object.simpleCache.saveMainHomeCards(type: .latest, datas: newCards)
                
                return .more((cards: cards, isUpdate: true))
            }
            .catch(self.catchClosure)
    }
}

extension MainHomeLatestViewReactor {
    
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
