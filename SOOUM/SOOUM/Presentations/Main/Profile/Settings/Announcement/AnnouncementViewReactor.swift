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
    }
    
    enum Mutation {
        case announcements([Announcement])
    }
    
    struct State {
        var announcements: [Announcement]
    }
    
    var initialState: State = .init(announcements: [])
    
    private let networkManager = NetworkManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            let request: SettingsRequest = .announcement
            
            return self.networkManager.request(AnnouncementResponse.self, request: request)
                .flatMapLatest { response -> Observable<Mutation> in
                    return .just(.announcements(response.embedded.announcements))
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .announcements(announcements):
            state.announcements = announcements
        }
        return state
    }
}
