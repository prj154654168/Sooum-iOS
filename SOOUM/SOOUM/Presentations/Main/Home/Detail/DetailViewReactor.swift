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
    }
    
    enum Mutation {
        case detailCard(Card)
    }
    
    struct State {
        var detailCard: Card
    }
    
    var initialState: State = .init(detailCard: .init())
    
    private let prevCard: Card
    
    init(prevCard: Card) {
        self.prevCard = prevCard
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return .just(.detailCard(self.prevCard))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .detailCard(let detailCard):
            state.detailCard = detailCard
        }
        return state
    }
}
