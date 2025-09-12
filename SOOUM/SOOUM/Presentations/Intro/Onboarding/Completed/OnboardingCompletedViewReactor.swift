//
//  OnboardingCompletedViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/25.
//

import ReactorKit

class OnboardingCompletedViewReactor: Reactor {
    
    typealias Action = NoAction
    typealias Mutation = NoMutation
    
    struct State { }
    
    var initialState: State { .init() }
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
}

extension OnboardingCompletedViewReactor {
    
    func reactorForMainTabBar() -> MainTabBarReactor {
        MainTabBarReactor(provider: self.provider)
    }
}
