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
        case updateFavorite
    }
    
    enum Mutation {
        /// 해당 태그 정보 fetch
        case tagInfo(TagInfoResponse)
        /// 태그 카드 fetch
        case tagCards([TagDetailCardResponse.TagFeedCard])
        /// 태그 즐겨찾기 여부 변경
        case updateFavorite(TagInfoResponse)
        case setLoading(Bool)
    }
    
    struct State {
        /// 태그 카드 리스트
        fileprivate(set) var tagCards: [TagDetailCardResponse.TagFeedCard] = []
        fileprivate(set) var tagInfo: TagInfoResponse?
        fileprivate(set) var isLoading: Bool = false
    }
    
    var initialState = State()
    
    let provider: ManagerProviderType
    
    private let tagID: String
  
    var emptyTagMode: EmptyTagDetailTableViewCell.Mode {
      // guard let cardCnt = self.currentState.tagInfo?.cardCnt else {
      //   return .noCardsRegistered
      // }
      // return cardCnt == 0 ? .noCardsRegistered : .noCardsCanView
        return .noCardsCanView
    }
    
    init(provider: ManagerProviderType, tagID: String) {
        self.provider = provider
        self.tagID = tagID
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchTagCards:
            return .concat([
                .just(.setLoading(true)),
                self.fetchTagCards()
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.setLoading(false))
            ])
            
        case .fetchTagInfo:
            return .concat([
                .just(.setLoading(true)),
                self.fetchTagInfo()
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.setLoading(false))
            ])
            
        case .updateFavorite:
            return updateFavorite()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .tagCards(tagCards):
            newState.tagCards = tagCards
            
        case let .tagInfo(tagInfo):
            newState.tagInfo = tagInfo
            
        case let .updateFavorite(tagInfo):
            newState.tagInfo = tagInfo
            
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
    
    private func fetchTagCards() -> Observable<Mutation> {
        let request: TagRequest = .tagCard(tagID: tagID)
        
        return self.provider.networkManager.request(TagDetailCardResponse.self, request: request)
            .map { response in
                return Mutation.tagCards(response.embedded.tagFeedCardDtoList)
            }
            .catch { _ in
                return .just(.tagCards([]))
            }
    }
    
    private func fetchTagInfo() -> Observable<Mutation> {
        let request: TagRequest = .tagInfo(tagID: tagID)
        
        return self.provider.networkManager.request(TagInfoResponse.self, request: request)
            .map { response in
                return Mutation.tagInfo(response)
            }
    }
    
    private func updateFavorite() -> Observable<Mutation> {
        guard let tagInfo = self.currentState.tagInfo else {
            return .empty()
        }
        
        // let request: TagRequest = tagInfo.isFavorite ? .deleteFavorite(tagID: tagID) : .addFavorite(tagID: tagID)

        // return self.provider.networkManager.request(AddFavoriteTagResponse.self, request: request)
        //     .map { _ in
        //         let newTagInfo = TagInfoResponse(
        //             content: tagInfo.content,
        //             cardCnt: tagInfo.cardCnt,
        //             isFavorite: !tagInfo.isFavorite,
        //             status: tagInfo.status
        //         )
        //         return Mutation.updateFavorite(newTagInfo)
        //     }
        return .empty()
    }
}

extension TagDetailViewrReactor {
    
    // func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
    //     DetailViewReactor(provider: self.provider, selectedId)
    // }
}
