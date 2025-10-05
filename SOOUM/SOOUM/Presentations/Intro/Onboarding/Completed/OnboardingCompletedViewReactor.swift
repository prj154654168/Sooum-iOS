//
//  OnboardingCompletedViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/25.
//

import ReactorKit

import Alamofire

class OnboardingCompletedViewReactor: Reactor {
    
    typealias Action = NoAction
    typealias Mutation = NoMutation
    
    struct State { }
    var initialState: State { .init() }
    
    private let dependencies: AppDIContainerable
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
    }
}

extension OnboardingCompletedViewReactor {
    
    func reactorForNotification() -> NotificationViewReactor {
        NotificationViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForMainTabBar() -> MainTabBarReactor {
        MainTabBarReactor(dependencies: self.dependencies)
    }
}
