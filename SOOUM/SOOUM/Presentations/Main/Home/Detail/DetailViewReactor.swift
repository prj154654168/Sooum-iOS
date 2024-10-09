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
        case updateCoordinate(String, String)
        case updateIsLoading(Bool)
    }
    
    struct State {
        var detailCard: DetailCard
        var coordinate: (String?, String?)
        var isLoading: Bool
    }
    
    var initialState: State = .init(
        detailCard: .init(),
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
                self.refresh(),
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
        case let .updateCoordinate(latitude, longitude):
            state.coordinate = (latitude, longitude)
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        }
        return state
    }
    
    
    func refresh() -> Observable<Mutation> {
        
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
}
