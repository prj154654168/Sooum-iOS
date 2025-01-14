//
//  MainHomeTabBarReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import ReactorKit

import Alamofire


class MainHomeTabBarReactor: Reactor {

    enum Action: Equatable {
        case notisWithoutRead
        case requestRead(String)
    }
    
    
    enum Mutation {
        case notisWithoutRead(Bool)
        case updateIsReadCompleted(Bool)
    }
    
    struct State {
        var noNotisWithoutRead: Bool
        var isReadCompleted: Bool
    }
    
    var initialState: State = .init(
        noNotisWithoutRead: true,
        isReadCompleted: false
    )
    
    private let networkManager = NetworkManager.shared
    let locationManager = LocationManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .notisWithoutRead:
            let request: NotificationRequest = .totalWithoutReadCount
            
            return self.networkManager.request(WithoutReadNotisCountResponse.self, request: request)
                .map { $0.unreadCnt == "0" }
                .map(Mutation.notisWithoutRead)
        case let .requestRead(selectedId):
            let request: NotificationRequest = .requestRead(notificationId: selectedId)
            return self.networkManager.request(Empty.self, request: request)
                .map { _ in .updateIsReadCompleted(true) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .notisWithoutRead(noNotisWithoutRead):
            state.noNotisWithoutRead = noNotisWithoutRead
        case let .updateIsReadCompleted(isReadCompleted):
            state.isReadCompleted = isReadCompleted
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
