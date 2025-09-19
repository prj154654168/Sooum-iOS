//
//  OnboardingCompletedViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/25.
//

import ReactorKit

import Alamofire

class OnboardingCompletedViewReactor: Reactor {
    
    // typealias Action = NoAction
    // typealias Mutation = NoMutation
    
    // struct State { }
    // var initialState: State { .init() }
    
    enum Action {
        case withdraw
    }
    
    enum Mutation {
        case withdraw(Bool)
    }
    
    struct State {
        var isSuccess: Bool
    }
    
    var initialState: State = State(isSuccess: false)
    
    private let dependencies: AppDIContainerable
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .withdraw:
            
            let managers = self.dependencies.rootContainer.resolve(ManagerProviderType.self)
            return managers.networkManager.perform(Empty.self, request: AuthRequest.withdraw(token: managers.authManager.authInfo.token))
                .map { _ in true }
                .map(Mutation.withdraw)
        }
    }
    
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .withdraw(let isSuccess):
            state.isSuccess = isSuccess
            self.dependencies.rootContainer.resolve(ManagerProviderType.self).authManager.initializeAuthInfo()
        }
        return state
    }
}

extension OnboardingCompletedViewReactor {
    
    // TODO: 임시, 계정 삭제 후 런치 화면으로 이동
    func reaactorForLaunch() -> LaunchScreenViewReactor {
        LaunchScreenViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForMainTabBar() -> MainTabBarReactor {
        MainTabBarReactor(provider: self.dependencies.rootContainer.resolve(ManagerProviderType.self))
    }
}
