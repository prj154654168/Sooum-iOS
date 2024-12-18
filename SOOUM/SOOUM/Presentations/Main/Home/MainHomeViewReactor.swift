//
//  MainHomeViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import ReactorKit

import Kingfisher


class MainHomeViewReactor: Reactor {
    
    // isUpdate == true 일 때, more
    typealias CardsWithUpdate = (cards: [Card], isUpdate: Bool)
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFind(lastId: String?)
        case homeTabBarItemDidTap(index: Int)
        case distanceFilter(String)
    }
    
    enum Mutation {
        case cards(CardsWithUpdate)
        case more(CardsWithUpdate)
        case updateSelectedIndex(Int)
        case updateDistanceFilter(String)
        case updateIsLoading(Bool)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var displayedCardsWithUpdate: CardsWithUpdate
        var selectedIndex: Int
        var distanceFilter: String
        var isLoading: Bool
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        displayedCardsWithUpdate: (cards: [], isUpdate: false),
        selectedIndex: 0,
        distanceFilter: "UNDER_1",
        isLoading: false,
        isProcessing: false
    )
    
    private let networkManager = NetworkManager.shared
    let locationManager = LocationManager.shared
    
    let simpleCache = SimpleCache.shared
    
    private let countPerLoading: Int = 12
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            return .concat([
                .just(.updateIsProcessing(true)),
                self.refresh(self.currentState.selectedIndex)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsProcessing(false))
            ])
        case .refresh:
            let selectedIndex = self.currentState.selectedIndex
            let distancFilter = self.currentState.distanceFilter
            
            return .concat([
                .just(.updateIsLoading(true)),
                self.refresh(selectedIndex, distancFilter)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsLoading(false))
            ])
        case let .moreFind(lastId):
            guard let lastId = lastId else {
                // 캐시된 데이터가 존재할 때
                var cardType: SimpleCache.CardType {
                    switch self.currentState.selectedIndex {
                    case 2: return .distance
                    default: return .latest
                    }
                }
                
                let loadedCards = self.simpleCache.loadMainHomeCards(type: cardType) ?? []
                let displayedCards = self.separate(
                    displayed: self.currentState.displayedCardsWithUpdate.cards,
                    current: loadedCards
                )
                return .just(.more((cards: displayedCards, isUpdate: true)))
            }
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.moreFind(lastId)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsProcessing(false))
            ])
        
        // 탭간 전환 시 이미 로딩된 탭 데이터는 로딩 X
        case let .homeTabBarItemDidTap(index):
            
            var cardType: SimpleCache.CardType {
                switch index {
                case 1: return .popular
                case 2: return .distance
                default: return .latest
                }
            }
            
            if self.simpleCache.isEmpty(type: cardType) {
                return .concat([
                    .just(.updateIsProcessing(true)),
                    .just(.updateSelectedIndex(index)),
                    self.refresh(index)
                        .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                    .just(.updateIsProcessing(false))
                ])
            } else {
                let cards = self.simpleCache.loadMainHomeCards(type: cardType) ?? []
                let displayedCards = self.separate(displayed: [], current: cards)
                return .concat([
                    .just(.updateSelectedIndex(index)),
                    .just(.cards((cards: displayedCards, isUpdate: false)))
                ])
            }
            
        case let .distanceFilter(distanceFilter):
            return .concat([
                .just(.updateIsProcessing(true)),
                .just(.updateDistanceFilter(distanceFilter)),
                self.refresh(2, distanceFilter)
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
            state.displayedCardsWithUpdate.cards += displayedCardsWithUpdate.cards
            state.displayedCardsWithUpdate.isUpdate = displayedCardsWithUpdate.isUpdate
        case let .updateSelectedIndex(selectedIndex):
            state.selectedIndex = selectedIndex
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
    
    func refresh(_ selectedIndex: Int, _ distanceFilter: String? = nil) -> Observable<Mutation> {
        
        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        var request: CardRequest {
            switch selectedIndex {
            case 1:
                return .popularCard(latitude: latitude, longitude: longitude)
            case 2:
                return .distancCard(
                    id: nil,
                    latitude: latitude,
                    longitude: longitude,
                    distanceFilter: distanceFilter ?? "UNDER_1"
                )
            default:
                return .latestCard(id: nil, latitude: latitude, longitude: longitude)
            }
        }
        
        switch selectedIndex {
        case 1:
            return self.networkManager.request(PopularCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { cards in
                    
                    // 서버 응답 캐싱
                    self.simpleCache.saveMainHomeCards(type: .popular, datas: cards)
                    // 표시할 데이터만 나누기
                    let displayedCards = self.separate(displayed: [], current: cards)
                    
                    return .cards((cards: displayedCards, isUpdate: false))
                }
                .catch(self.catchClosure)
        case 2:
            return self.networkManager.request(DistanceCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { cards in
                    
                    // 서버 응답 캐싱
                    self.simpleCache.saveMainHomeCards(type: .distance, datas: cards)
                    // 표시할 데이터만 나누기
                    let displayedCards = self.separate(displayed: [], current: cards)
                    
                    return .cards((cards: displayedCards, isUpdate: false))
                }
                .catch(self.catchClosure)
        default:
            return self.networkManager.request(LatestCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { cards in
                    
                    // 서버 응답 캐싱
                    self.simpleCache.saveMainHomeCards(type: .latest, datas: cards)
                    // 표시할 데이터만 나누기
                    let displayedCards = self.separate(displayed: [], current: cards)
                    return .cards((cards: displayedCards, isUpdate: false))
                }
                .catch(self.catchClosure)
        }
    }
    
    func moreFind(_ lastId: String) -> Observable<Mutation> {
        
        let selectedIndex = self.currentState.selectedIndex
        if selectedIndex == 1 { return .empty() }
        
        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        let distanceFilter = self.currentState.distanceFilter
        
        var request: CardRequest {
            switch selectedIndex {
            case 2:
                return .distancCard(
                    id: lastId,
                    latitude: latitude,
                    longitude: longitude,
                    distanceFilter: distanceFilter
                )
            default:
                return .latestCard(id: lastId, latitude: latitude, longitude: longitude)
            }
        }
        
        if selectedIndex == 0 {
            return self.networkManager.request(LatestCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { cards in
                    
                    let loadedCards = self.simpleCache.loadMainHomeCards(type: .latest) ?? []
                    var newCards = loadedCards
                    newCards += cards
                    
                    self.simpleCache.saveMainHomeCards(type: .latest, datas: newCards)
                    
                    let displayedCards = self.separate(displayed: loadedCards, current: newCards)
                    return .more((cards: displayedCards, isUpdate: true))
                }
                .catch(self.catchClosure)
        } else {
            return self.networkManager.request(DistanceCardResponse.self, request: request)
                .map(\.embedded.cards)
                .map { cards in
                    
                    let loadedCards = self.simpleCache.loadMainHomeCards(type: .distance) ?? []
                    var newCards = loadedCards
                    newCards += cards
                    
                    self.simpleCache.saveMainHomeCards(type: .distance, datas: newCards)
                    
                    let displayedCards = self.separate(displayed: loadedCards, current: newCards)
                    return .more((cards: displayedCards, isUpdate: true))
                }
                .catch(self.catchClosure)
        }
    }
}

/// Hand oveer reactor
extension MainHomeViewReactor {
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor(type: .mainHome, selectedId)
    }
}

extension MainHomeViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.updateIsProcessing(false)),
                .just(.updateIsLoading(false))
            ])
        }
    }
    
    func separate(displayed displayedCards: [Card], current cards: [Card]) -> [Card] {
        let count = displayedCards.count
        let displayedCards = Array(cards[count..<min(count + self.countPerLoading, cards.count)])
        return displayedCards
    }
}
