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
        case refresh
        case moreFind(String)
    }
    
    enum Mutation {
        case commentHistories([CommentHistory])
        case more([CommentHistory])
        case updateIsProcessing(Bool)
        case updateIsLoading(Bool)
    }
    
    struct State {
        var commentHistories: [CommentHistory]
        var isProcessing: Bool
        var isLoading: Bool
    }
    
    var initialState: State = .init(
        commentHistories: [],
        isProcessing: false,
        isLoading: false
    )
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            let request: SettingsRequest = .commentHistory(lastId: nil)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.provider.networkManager.request(CommentHistoryResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.commentHistories(response.embedded.commentHistories))
                    }
                    .delaySubscription(.milliseconds(500), scheduler: MainScheduler.instance)
                    .catch(self.catchClosure),
                .just(.updateIsProcessing(false))
            ])
        case .refresh:
            
            let request: SettingsRequest = .commentHistory(lastId: nil)
            
            return .concat([
                .just(.updateIsLoading(true)),
                self.provider.networkManager.request(CommentHistoryResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.commentHistories(response.embedded.commentHistories))
                    }
                    .delaySubscription(.milliseconds(500), scheduler: MainScheduler.instance)
                    .catch(self.catchClosure),
                .just(.updateIsLoading(false))
            ])
        case let .moreFind(lastId):
            let request: SettingsRequest = .commentHistory(lastId: lastId)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.provider.networkManager.request(CommentHistoryResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.more(response.embedded.commentHistories))
                    }
                    .delaySubscription(.milliseconds(500), scheduler: MainScheduler.instance)
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
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        }
        return state
    }
}

extension CommentHistroyViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.updateIsProcessing(false)),
                .just(.updateIsLoading(false))
            ])
        }
    }
}

extension CommentHistroyViewReactor {
    
    // func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
    //     DetailViewReactor(provider: self.provider, selectedId)
    // }
}
