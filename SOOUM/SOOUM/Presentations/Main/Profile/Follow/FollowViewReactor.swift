//
//  FollowViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit


class FollowViewReactor: Reactor {
    
    enum EntranceType {
        case following
        case follower
    }
    
    enum Action: Equatable {
        case landing
    }
    
    enum Mutation {
        case follows([Follow])
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var follows: [Follow]
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        follows: [],
        isProcessing: false
    )
    
    let entranceType: EntranceType
    let memberId: String
    
    init(type entranceType: EntranceType, memberId: String) {
        self.entranceType = entranceType
        self.memberId = memberId
    }
    
    private let networkManager = NetworkManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            var request: ProfileRequest {
                switch self.entranceType {
                case .following:
                    return .following(memberId: self.memberId)
                case .follower:
                    return .follower(memberId: self.memberId)
                }
            }
            
            switch self.entranceType {
            case .following:
                return self.networkManager.request(FollowingResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.follows(response.embedded.followings))
                    }
            case .follower:
                return self.networkManager.request(FollowerResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.follows(response.embedded.followers))
                    }
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
        case let .follows(follows):
            state.follows = follows
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        }
        return state
    }
}
