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
        case resign
        case updateReason(WithdrawType)
        case updateOtherReason(String)
    }
    
    enum Mutation {
        case updateReason(WithdrawType)
        case updateOtherReason(String?)
        case updateIsSuccess(Bool)
    }
    
    struct State {
        fileprivate(set) var reason: WithdrawType?
        fileprivate(set) var otherReason: String?
        fileprivate(set) var isSuccess: Bool?
    }
    
    var initialState: State = .init(
        reason: nil,
        otherReason: nil,
        isSuccess: nil
    )
    
    private let dependencies: AppDIContainerable
    private let authUseCase: AuthUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.authUseCase = dependencies.rootContainer.resolve(AuthUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .resign:
            
            guard let reason = self.currentState.reason else { return .empty() }
            
            return self.authUseCase.withdraw(
                reaseon: reason == .other ?
                    (self.currentState.otherReason ?? reason.message) :
                    reason.message
            )
            .map { isSuccess in
                // 사용자 닉네임 제거
                UserDefaults.standard.nickname = nil
                
                return isSuccess
            }
            .map(Mutation.updateIsSuccess)
        case let .updateReason(reason):
            
            return .just(.updateReason(reason))
        case let .updateOtherReason(otherReason):
            
            return .just(.updateOtherReason(otherReason))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .updateReason(reason):
            newState.reason = reason
        case let .updateOtherReason(otherReason):
            newState.otherReason = otherReason
        case let .updateIsSuccess(isSuccess):
            newState.isSuccess = isSuccess
        }
        return newState
    }
}

extension ResignViewReactor {
    
    func reactorForOnboarding() -> OnboardingViewReactor {
        OnboardingViewReactor(dependencies: self.dependencies)
    }
}
