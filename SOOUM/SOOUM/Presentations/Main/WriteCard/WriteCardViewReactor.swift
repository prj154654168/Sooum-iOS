//
//  WriteCardViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 10/20/24.
//

import ReactorKit


class WriteCardViewReactor: Reactor {
    
    enum Action: Equatable {
        case writeCard
        case relatedTags(keyword: String)
    }
    
    enum Mutation {
        case relatedTags([RelatedTag])
    }
    
    struct State {
        var relatedTags: [RelatedTag]
    }
    
    var initialState: State = .init(
        relatedTags: []
    )
    
    private let networkManager = NetworkManager.shared
    
    init() { }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .writeCard:
            return .empty()
        case .relatedTags(let keyword):
            
            let request: CardRequest = .relatedTag(keyword: keyword, size: 5)
            
            return self.networkManager.request(RelatedTagResponse.self, request: request)
                .map(\.embedded.relatedTags)
                .map { .relatedTags($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
        case let .relatedTags(relatedTags):
            state.relatedTags = relatedTags
        }
        return state
    }
}
