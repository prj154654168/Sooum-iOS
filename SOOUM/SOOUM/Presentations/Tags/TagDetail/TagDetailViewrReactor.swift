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
        case fetchTagInfo
        case addFavorite
    }
    
    enum Mutation {
        /// 해당 태그 정보 fetch
        case tagInfo(TagInfoResponse)
        /// 태그 카드 fetch
        case tagCards([TagDetailCardResponse.TagFeedCard])
    }
    
    struct State {
        /// 태그 카드 리스트
        fileprivate(set) var tagCards: [TagDetailCardResponse.TagFeedCard] = []
        fileprivate(set) var tagInfo: TagInfoResponse?
    }
    
    var initialState = State()
    
    private let tagID: String
    
    init(initialState: State = State(), tagID: String) {
        self.initialState = initialState
        self.tagID = tagID
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchTagCards:
            return self.fetchTagCards()
            
        case .fetchTagInfo:
            return self.fetchTagInfo()
            
        case .addFavorite:
            <#code#>
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .tagCards(tagCards):
            newState.tagCards = tagCards
            
        case let .tagInfo(tagInfo):
            newState.tagInfo = tagInfo
        }
        return newState
    }
    
    private func fetchTagCards() -> Observable<Mutation> {
        let request: TagRequest = .tagCard(tagID: tagID)
        
        return NetworkManager.shared.request(TagDetailCardResponse.self, request: request)
            .map { response in
                return Mutation.tagCards(response.embedded.tagFeedCardDtoList)
            }
            .catch { _ in
                print("\(type(of: self)) - \(#function) - catch")
                return .just(.tagCards([]))
            }
    }
    
    private func fetchTagInfo() -> Observable<Mutation> {
        let request: TagRequest = .tagInfo(tagID: tagID)
        
        return NetworkManager.shared.request(TagInfoResponse.self, request: request)
            .map { response in
                return Mutation.tagInfo(response)
            }
    }
    
    private func addFavorite() -> Observable<Mutation> {
        guard let isFavorite = self.currentState.tagInfo?.isFavorite else {
            return .empty()
        }
        
        return NetworkManager.shared.request(TagInfoResponse.self, request: request)
            .map { _ in
                return Mutation.tagInfo(response)
            }
    }
    
    
}
