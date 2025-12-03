//
//  EnterMemberTransferViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit

import Alamofire


class EnterMemberTransferViewReactor: Reactor {
    
    enum EntranceType {
        case onboarding
        case settings
    }
    
    enum Action: Equatable {
        case enterTransferCode(String)
    }
    
    enum Mutation {
        case enterTransferCode(Bool?)
    }
    
    struct State {
        var isSuccess: Bool?
    }
    
    var initialState: State = State(isSuccess: nil)
    
    private let dependencies: AppDIContainerable
    private let authUseCase: AuthUseCase
    private let transferAccountUseCase: TransferAccountUseCase
  
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.authUseCase = dependencies.rootContainer.resolve(AuthUseCase.self)
        self.transferAccountUseCase = dependencies.rootContainer.resolve(TransferAccountUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .enterTransferCode(transferCode):
            
            return .concat([
                .just(.enterTransferCode(nil)),
                self.authUseCase.encryptedDeviceId()
                    .withUnretained(self)
                    .flatMapLatest { object, encryptedDeviceId -> Observable<Mutation> in
                        
                        if let encryptedDeviceId = encryptedDeviceId {
                            return object.transferAccountUseCase.enter(
                                code: transferCode,
                                encryptedDeviceId: encryptedDeviceId
                            )
                                .flatMapLatest { isSuccess -> Observable<Mutation> in
                                    if isSuccess { object.authUseCase.initializeAuthInfo() }
                                    
                                    return .just(.enterTransferCode(isSuccess))
                                }
                        } else {
                            return .just(.enterTransferCode(false))
                        }
                    }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .enterTransferCode(isSuccess):
            state.isSuccess = isSuccess
        }
        return state
    }
}

extension EnterMemberTransferViewReactor {
    
    func reactorForOnborading() -> OnboardingViewReactor {
        OnboardingViewReactor(dependencies: self.dependencies)
    }
}
