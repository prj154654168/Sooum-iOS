//
//  MainHomeTabBarReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import ReactorKit


class MainHomeTabBarReactor: Reactor {

    enum Action: Equatable {
        case notisWithoutRead
    }
    
    
    enum Mutation {
        case notisWithoutRead(Bool)
    }
    
    struct State {
        var isNotisWithoutRead: Bool
    }
    
    var initialState: State = .init(isNotisWithoutRead: false)
    
    private let networkManager = NetworkManager.shared
    let locationManager = LocationManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .notisWithoutRead:
            let request: NotificationRequest = .totalWithoutRead(lastId: nil)
            
            return self.networkManager.request(CommentHistoryInNotiResponse.self, request: request)
                .map { $0.commentHistoryInNotis.isEmpty }
                .map(Mutation.notisWithoutRead)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .notisWithoutRead(isNotisWithoutRead):
            state.isNotisWithoutRead = isNotisWithoutRead
        }
        return state
    }
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
        DetailViewReactor.init(selectedId)
    }
    
    func reactorForNoti() -> NotificationTabBarReactor {
        NotificationTabBarReactor.init()
    }
}
