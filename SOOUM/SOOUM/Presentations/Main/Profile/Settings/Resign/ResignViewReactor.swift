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
    
    private let networkManager = NetworkManager.shared
    private let authManager = AuthManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .check(isCheck):
            return .just(.updateCheck(!isCheck))
        case .resign:
            let requset: SettingsRequest = .resign(token: self.authManager.authInfo.token)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.networkManager.request(Empty.self, request: requset)
                    .withUnretained(self)
                    .flatMapLatest { object, _ -> Observable<Mutation> in
                        object.authManager.initializeAuthInfo()
                        
                        return .just(.updateIsSuccess(true))
                    },
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
