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
    
    var initialState: State {
        .init()
    }
    
    let locationManager = LocationManager.shared
}

extension NotificationTabBarReactor {
    
    func reactorForTotal() -> NotificationViewReactor {
        NotificationViewReactor.init(.total)
    }
    
    func reactorForComment() -> NotificationViewReactor {
        NotificationViewReactor.init(.comment)
    }
    
    func reactorForLike() -> NotificationViewReactor {
        NotificationViewReactor.init(.like)
    }
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor.init(selectedId)
    }
}
