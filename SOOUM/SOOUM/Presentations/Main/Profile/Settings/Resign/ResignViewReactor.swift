//
//  ResignViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit

import Alamofire


class ResignViewReactor: Reactor {
    
    enum Action: Equatable {
        case check(Bool)
        case resign
    }
    
    enum Mutation {
        case updateCheck(Bool)
        case updateIsSuccess(Bool)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var isCheck: Bool
        var isSuccess: Bool
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        isCheck: false,
        isSuccess: false,
        isProcessing: false
    )
    
    let provider: ManagerProviderType
    
    let banEndAt: Date?
    
    init(provider: ManagerProviderType, banEndAt: Date? = nil) {
        self.provider = provider
        self.banEndAt = banEndAt
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .check(isCheck):
            return .just(.updateCheck(!isCheck))
        case .resign:
            let requset: SettingsRequest = .resign(token: self.provider.authManager.authInfo.token)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.provider.networkManager.request(Status.self, request: requset)
                    .withUnretained(self)
                    .flatMapLatest { object, _ -> Observable<Mutation> in
                        object.provider.authManager.initializeAuthInfo()
                        
                        return .concat([
                            object.provider.pushManager.switchNotification(on: false)
                                .flatMapLatest { error -> Observable<Mutation> in .empty() },
                            .just(.updateIsSuccess(true))
                        ])
                    }
                    .catch(self.catchClosure),
                .just(.updateIsProcessing(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .updateCheck(isCheck):
            state.isCheck = isCheck
        case let .updateIsSuccess(isSuccess):
            state.isSuccess = isSuccess
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        }
        return state
    }
}

extension ResignViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.updateIsProcessing(false))
            ])
        }
    }
}
