//
//  NotificationTabBarReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import ReactorKit


class NotificationTabBarReactor: Reactor {

    typealias Action = NoAction
    typealias Mutation = NoMutation
    
    struct State { }
    
    var initialState: State { .init() }
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
}

extension NotificationTabBarReactor {
    
    func reactorForTotal() -> NotificationViewReactor {
        NotificationViewReactor(provider: self.provider, .total)
    }
    
    func reactorForComment() -> NotificationViewReactor {
        NotificationViewReactor(provider: self.provider, .comment)
    }
    
    func reactorForLike() -> NotificationViewReactor {
        NotificationViewReactor(provider: self.provider, .like)
    }
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor(provider: self.provider, selectedId)
    }
}
