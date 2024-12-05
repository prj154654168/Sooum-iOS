//
//  TagDetailViewrReactor.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import ReactorKit
import RxSwift

class TagDetailViewrReactor: Reactor {
    
    enum Action {
        case fetchTagCards
    }
    
    enum Mutation {
        /// 태그 카드 fetch
        case tagCards([TagDetailCardResponse.TagFeedCard])
    }
    
    struct State {
        /// 태그 카드 리스트
        fileprivate(set) var tagCards: [TagDetailCardResponse.TagFeedCard] = []
    }
    
    var initialState = State()
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchTagCards:
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .tagCards(tagCards):
            newState.tagCards = tagCards
        }
        return newState
    }
    
    private func fetchTagCards() -> Observable<Mutation> {
        let request: TagRequest = .
        
        return NetworkManager.shared.request(FavoriteTagsResponse.self, request: request)
            .map { response in
                return Mutation.favoriteTags(response.embedded.favoriteTagList)
            }
            .catch { _ in
                print("\(type(of: self)) - \(#function) - catch")
                return .just(.favoriteTags([]))
            }
    }
    
}
