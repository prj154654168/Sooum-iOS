//
//  TagSearchViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 11/22/25.
//

import ReactorKit

class TagSearchViewReactor: Reactor {
    
    enum Action: Equatable {
        case reset
        case search(String)
    }
    
    enum Mutation {
        case searchTerms([TagInfo]?)
        case updateIsUpdate(Bool?)
    }
    
    struct State {
        fileprivate(set) var searchTerms: [TagInfo]?
        fileprivate(set) var isUpdated: Bool?
    }
    
    var initialState: State = .init(
        searchTerms: nil,
        isUpdated: nil
    )
    
    private let dependencies: AppDIContainerable
    private let fetchTagUseCase: FetchTagUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.fetchTagUseCase = dependencies.rootContainer.resolve(FetchTagUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reset:
            
            return .just(.searchTerms(nil))
        case let .search(terms):
            
            return self.fetchTagUseCase.related(keyword: terms, size: 20)
                .map(Mutation.searchTerms)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .searchTerms(searchTerms):
            newState.searchTerms = searchTerms
        case let .updateIsUpdate(isUpdated):
            newState.isUpdated = isUpdated
        }
        return newState
    }
}

extension TagSearchViewReactor {
    
    func reactorForSearchCollect(with id: String, title: String) -> TagSearchCollectViewReactor {
        TagSearchCollectViewReactor(dependencies: self.dependencies, with: id, title: title)
    }
}
