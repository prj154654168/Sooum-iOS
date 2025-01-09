//
//  CommentHistroyViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit


class CommentHistroyViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case moreFind(String)
    }
    
    enum Mutation {
        case commentHistories([CommentHistory])
        case more([CommentHistory])
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var commentHistories: [CommentHistory]
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        commentHistories: [],
        isProcessing: false
    )
    
    private let networkManager = NetworkManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            let request: SettingsRequest = .commentHistory(lastId: nil)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.networkManager.request(CommentHistoryResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.commentHistories(response.embedded.commentHistories))
                    }
                    .delaySubscription(.seconds(1), scheduler: MainScheduler.instance)
                    .catch(self.catchClosure),
                .just(.updateIsProcessing(false))
            ])
        case let .moreFind(lastId):
            let request: SettingsRequest = .commentHistory(lastId: lastId)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.networkManager.request(CommentHistoryResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.more(response.embedded.commentHistories))
                    }
                    .delaySubscription(.seconds(1), scheduler: MainScheduler.instance)
                    .catch(self.catchClosure),
                .just(.updateIsProcessing(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .commentHistories(commentHistories):
            state.commentHistories = commentHistories
        case let .more(commentHistories):
            state.commentHistories += commentHistories
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        }
        return state
    }
}

extension CommentHistroyViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.updateIsProcessing(false))
            ])
        }
    }
}

extension CommentHistroyViewReactor {
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor.init(selectedId)
    }
}
