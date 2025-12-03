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
        case updateIsFavorite(String, Bool)
    }
    
    enum Mutation {
        case searchTerms([TagInfo]?)
        case updateIsUpdate(Bool?)
        case updateIsFavorite(Bool)
    }
    
    struct State {
        fileprivate(set) var searchTerms: [TagInfo]?
        fileprivate(set) var isUpdated: Bool?
        fileprivate(set) var isFavorite: Bool
    }
    
    var initialState: State = .init(
        searchTerms: nil,
        isUpdated: nil,
        isFavorite: false
    )
    
    private let dependencies: AppDIContainerable
    private let fetchTagUseCase: FetchTagUseCase
    private let updateTagFavoriteUseCase: UpdateTagFavoriteUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.fetchTagUseCase = dependencies.rootContainer.resolve(FetchTagUseCase.self)
        self.updateTagFavoriteUseCase = dependencies.rootContainer.resolve(UpdateTagFavoriteUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reset:
            
            return .just(.searchTerms(nil))
        case let .search(terms):
            
            return self.fetchTagUseCase.related(keyword: terms, size: 20)
                .map(Mutation.searchTerms)
        case let .updateIsFavorite(tagId, isFavorite):
            
            return .concat([
                .just(.updateIsUpdate(nil)),
                self.updateTagFavoriteUseCase.updateFavorite(tagId: tagId, isFavorite: !isFavorite)
                    .flatMapLatest { isUpdated -> Observable<Mutation> in
                        
                        let isFavorite = isUpdated ? !isFavorite : isFavorite
                        return .concat([
                            .just(.updateIsFavorite(isFavorite)),
                            .just(.updateIsUpdate(isUpdated))
                        ])
                    }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .searchTerms(searchTerms):
            newState.searchTerms = searchTerms
        case let .updateIsUpdate(isUpdated):
            newState.isUpdated = isUpdated
        case let .updateIsFavorite(isFavorite):
            newState.isFavorite = isFavorite
        }
        return newState
    }
}

extension TagSearchViewReactor {
    
    func reactorForSearchCollect(with id: String, title: String) -> TagSearchCollectViewReactor {
        TagSearchCollectViewReactor(dependencies: self.dependencies, with: id, title: title)
    }
}
