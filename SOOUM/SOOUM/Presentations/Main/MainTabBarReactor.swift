//
//  MainTabBarReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import ReactorKit


class MainTabBarReactor: Reactor {
    
    typealias Coordinate = (latitude: String, longitude: String)
    
    enum Action {
        case coordinate(Coordinate)
    }
    
    enum Mutation {
        case updateCoordinate(Coordinate)
    }
    
    struct State {
        var coordinate: (Coordinate)
    }
    
    var initialState: State = .init(
        coordinate: ("", "")
    )
    
    init() { }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .coordinate(let coordinate):
            return .just(.updateCoordinate(coordinate))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
        case .updateCoordinate(let coordinate):
            state.coordinate = coordinate
        }
        return state
    }
}

extension MainTabBarReactor {
    
    func reactorForMainHome() -> MainHomeViewReactor {
        MainHomeViewReactor()
    }
}
