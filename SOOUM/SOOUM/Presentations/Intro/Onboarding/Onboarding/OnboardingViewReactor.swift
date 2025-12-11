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
        case check
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
    private let validateUserUseCase: ValidateUserUseCase
    private let updateNotifyUseCase: UpdateNotifyUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.validateUserUseCase = dependencies.rootContainer.resolve(ValidateUserUseCase.self)
        self.updateNotifyUseCase = dependencies.rootContainer.resolve(UpdateNotifyUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                self.validateUserUseCase.checkValidation()
                    .map(Mutation.check),
                self.updateNotifyUseCase.switchNotification(on: true)
                    .flatMapLatest { _ -> Observable<Mutation> in .empty() }
            ])
        case .check:
            
            return self.validateUserUseCase.checkValidation()
                .map(Mutation.check)
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
    
    func reactorForTermsOfService() -> OnboardingTermsOfServiceViewReactor {
        OnboardingTermsOfServiceViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForEnterTransfer() -> EnterMemberTransferViewReactor {
        EnterMemberTransferViewReactor(dependencies: self.dependencies)
    }
}
