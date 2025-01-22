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
        case updateError(Bool)
    }
    
    struct State {
        var isCheck: Bool
        var isSuccess: Bool
        var isProcessing: Bool
        var isError: Bool
    }
    
    var initialState: State = .init(
        isCheck: false,
        isSuccess: false,
        isProcessing: false,
        isError: false
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
                    .flatMapLatest { object, response -> Observable<Mutation> in
                        switch response.httpCode {
                        case 418:
                            return .just(.updateError(true))
                        case 0:
                            object.provider.authManager.initializeAuthInfo()
                            SimpleDefaults.shared.initRemoteNotificationActivation()
                            
                            return .concat([
                                object.provider.pushManager.switchNotification(on: false)
                                    .flatMapLatest { error -> Observable<Mutation> in .empty() },
                                .just(.updateIsSuccess(true))
                            ])
                        default:
                            return .empty()
                        }
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
        case let .updateError(isError):
            state.isError = isError
        }
        return state
    }
}

extension ResignViewReactor {
    
    func reactorForOnboarding() -> OnboardingViewReactor {
        OnboardingViewReactor(provider: self.provider)
    }
}

extension ResignViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { error in
            
            let nsError = error as NSError
            return .concat([
                .just(.updateError(nsError.code == 418)),
                .just(.updateIsProcessing(false))
            ])
        }
    }
}
