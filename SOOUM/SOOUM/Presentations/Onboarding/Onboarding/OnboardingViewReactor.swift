//
//  OnboardingViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 1/15/25.
//

import ReactorKit


class OnboardingViewReactor: Reactor {
    
    typealias Action = NoAction
    typealias Mutation = NoMutation

    struct State { }

    var initialState: State { .init() }
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
}

extension OnboardingViewReactor {
    
    func reactorForTermsOfService() -> OnboardingTermsOfServiceViewReactor {
        OnboardingTermsOfServiceViewReactor(provider: self.provider)
    }
    
    func reactorForEnterTransfer() -> EnterMemberTransferViewReactor {
        EnterMemberTransferViewReactor(provider: self.provider, entranceType: .onboarding)
    }
}
