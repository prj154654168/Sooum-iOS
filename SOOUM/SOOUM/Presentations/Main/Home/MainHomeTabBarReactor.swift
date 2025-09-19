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
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .notisWithoutRead:
           //  let request: NotificationRequest = .totalWithoutReadCount
           //
           //  return self.provider.networkManager.request(WithoutReadNotisCountResponse.self, request: request)
           //      .map { $0.unreadCnt == "0" }
           //      .map(Mutation.notisWithoutRead)
            return .empty()
        case let .requestRead(selectedId):
            let request: NotificationRequest = .requestRead(notificationId: selectedId)
            return self.provider.networkManager.request(Empty.self, request: request)
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
        MainHomeLatestViewReactor(provider: self.provider)
    }
    
    func reactorForPopular() -> MainHomePopularViewReactor {
        MainHomePopularViewReactor(provider: self.provider)
    }
    
    func reactorForDistance() -> MainHomeDistanceViewReactor {
        MainHomeDistanceViewReactor(provider: self.provider)
    }
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor.init(provider: self.provider, selectedId)
    }
    
    func reactorForNoti() -> NotificationTabBarReactor {
        NotificationTabBarReactor(provider: self.provider)
    }
}
