//
//  MainHomeTabBarReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import ReactorKit


class MainHomeTabBarReactor: Reactor {

    typealias Action = NoAction
    typealias Mutation = NoMutation
    
    struct State { }
    
    var initialState: State {
        .init()
    }
    
    let locationManager = LocationManager.shared
}

extension MainHomeTabBarReactor {
    
    func reactorForLatest() -> MainHomeLatestViewReactor {
        MainHomeLatestViewReactor.init()
    }
    
    func reactorForPopular() -> MainHomePopularViewReactor {
        MainHomePopularViewReactor.init()
    }
    
    func reactorForDistance() -> MainHomeDistanceViewReactor {
        MainHomeDistanceViewReactor.init()
    }
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor.init(type: .mainHome, selectedId)
    }
}
