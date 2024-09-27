//
//  LaunchScreenViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import ReactorKit


class LaunchScreenViewReactor: Reactor {
    
    /// 추후 로그인 api 가 개발 완료되면 로그인 비지니스 로직을 담당
    typealias Action = NoAction
    typealias Mutation = NoMutation
    
    struct State { }
    
    var initialState: State {
        .init()
    }
    
    init() { }
}

extension LaunchScreenViewReactor {
    
    func reactorForMainTabBar() -> MainTabBarReactor {
        MainTabBarReactor()
    }
}
