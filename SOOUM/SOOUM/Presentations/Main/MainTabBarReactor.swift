//
//  MainTabBarReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import ReactorKit


class MainTabBarReactor: Reactor {

    typealias Action = NoAction
    typealias Mutation = NoMutation
    
    struct State { }
    
    var initialState: State {
        .init()
    }
}

extension MainTabBarReactor {
    
    func reactorForMainHome() -> MainHomeTabBarReactor {
        MainHomeTabBarReactor.init()
    }
    
    func reactorForWriteCard() -> WriteCardViewReactor {
        WriteCardViewReactor(type: .card)
    }
    
    func reactorForProfile() -> ProfileViewReactor {
        ProfileViewReactor(type: .my, memberId: nil)
    }
}
