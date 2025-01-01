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
    }
    
    enum Mutation {
        case announcements([Announcement])
        case updateIsLoading(Bool)
    }
    
    struct State {
        var announcements: [Announcement]
        var isLoading: Bool
    }
    
    var initialState: State = .init(
        announcements: [],
        isLoading: false
    )
    
    private let networkManager = NetworkManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            let request: SettingsRequest = .announcement
            
            return self.networkManager.request(AnnouncementResponse.self, request: request)
                .flatMapLatest { response -> Observable<Mutation> in
                    return .just(.announcements(response.embedded.announcements))
                }
        case .refresh:
            let request: SettingsRequest = .announcement
            
            return .concat([
                .just(.updateIsLoading(true)),
                self.networkManager.request(AnnouncementResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.announcements(response.embedded.announcements))
                    }
                    .catch(self.catchClosure)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .announcements(announcements):
            state.announcements = announcements
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        }
        return state
    }
}

extension AnnouncementViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in .just(.updateIsLoading(false)) }
    }
}
