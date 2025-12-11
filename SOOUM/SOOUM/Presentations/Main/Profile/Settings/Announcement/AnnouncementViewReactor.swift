//
//  AnnouncementViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/6/24.
//

import ReactorKit

class AnnouncementViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case refresh
        case more(lastId: String)
    }
    
    enum Mutation {
        case announcements([NoticeInfo])
        case more([NoticeInfo])
        case updateIsRefreshing(Bool)
    }
    
    struct State {
        var announcements: [NoticeInfo]
        var isRefreshing: Bool
    }
    
    var initialState: State = .init(
        announcements: [],
        isRefreshing: false
    )
    
    private let dependencies: AppDIContainerable
    private let fetchNoticeUseCase: FetchNoticeUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.fetchNoticeUseCase = dependencies.rootContainer.resolve(FetchNoticeUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.fetchNoticeUseCase.notices(lastId: nil, size: 10, requestType: .settings)
                .map(Mutation.announcements)
        case .refresh:
            
            return .concat([
                .just(.updateIsRefreshing(true)),
                self.fetchNoticeUseCase.notices(lastId: nil, size: 10, requestType: .settings)
                    .map(Mutation.announcements)
                    .catchAndReturn(.updateIsRefreshing(false)),
                .just(.updateIsRefreshing(false))
            ])
        case let .more(lastId):
            
            return self.fetchNoticeUseCase.notices(lastId: lastId, size: 10, requestType: .settings)
                .map(Mutation.more)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .announcements(announcements):
            newState.announcements = announcements
        case let .more(announcements):
            newState.announcements += announcements
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        }
        return newState
    }
}
