//
//  OnboardingViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 1/15/25.
//

import ReactorKit


class OnboardingViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
    }
    
    
    enum Mutation {
        case check(CheckAvailable?)
    }

    struct State {
        fileprivate(set) var checkAvailable: CheckAvailable?
        fileprivate(set) var shouldHideTransfer: Bool
    }

    var initialState: State = .init(
        checkAvailable: nil,
        shouldHideTransfer: UserDefaults.standard.bool(forKey: "AppFlag")
    )
    
    private let dependencies: AppDIContainerable
    private let userUseCase: UserUseCase
    private let pushManager: PushManagerDelegate
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.userUseCase = dependencies.rootContainer.resolve(UserUseCase.self)
        let provider = dependencies.rootContainer.resolve(ManagerProviderType.self)
        self.pushManager = provider.pushManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                self.check(),
                self.pushManager.switchNotification(on: true)
                    .flatMapLatest { _ -> Observable<Mutation> in .empty() }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .check(checkAvailable):
            newState.checkAvailable = checkAvailable
        }
        return newState
    }
}

extension OnboardingViewReactor {
    
    private func check() -> Observable<Mutation> {
        
        return self.userUseCase.isAvailableCheck()
            .map(Mutation.check)
    }
}

extension OnboardingViewReactor {
    
    func reactorForTermsOfService() -> OnboardingTermsOfServiceViewReactor {
        OnboardingTermsOfServiceViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForEnterTransfer() -> EnterMemberTransferViewReactor {
        EnterMemberTransferViewReactor(dependencies: self.dependencies)
    }
}
