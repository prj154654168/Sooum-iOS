//
//  FollowViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit

import Alamofire


class FollowViewReactor: Reactor {
    
    enum EntranceType {
        case following
        case follower
    }
    
    enum ViewType {
        case my
        case other
    }
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFind(lastId: String)
        case request(String)
        case cancel(String)
    }
    
    enum Mutation {
        case follows([Follow])
        case more([Follow])
        case updateIsRequest(Bool)
        case updateIsCancel(Bool)
        case updateIsProcessing(Bool)
        case updateIsLoading(Bool)
    }
    
    struct State {
        var follows: [Follow]
        var isRequest: Bool
        var isCancel: Bool
        var isProcessing: Bool
        var isLoading: Bool
    }
    
    var initialState: State = .init(
        follows: [],
        isRequest: false,
        isCancel: false,
        isProcessing: false,
        isLoading: false
    )
    
    let entranceType: EntranceType
    let viewType: ViewType
    let memberId: String?
    
    init(type entranceType: EntranceType, view viewType: ViewType, memberId: String? = nil) {
        self.entranceType = entranceType
        self.viewType = viewType
        self.memberId = memberId
    }
    
    private let networkManager = NetworkManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            return .concat([
                .just(.updateIsProcessing(true)),
                self.refresh()
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsProcessing(false))
            ])
        case .refresh:
            return .concat([
                .just(.updateIsLoading(true)),
                self.refresh()
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsLoading(false))
            ])
        case let .moreFind(lastId):
            return .concat([
                .just(.updateIsProcessing(true)),
                self.more(lastId: lastId),
                .just(.updateIsProcessing(false))
            ])
        case let .request(memberId):
            let request: ProfileRequest = .requestFollow(memberId: memberId)
            
            return self.networkManager.request(Empty.self, request: request)
                .flatMapLatest { _ -> Observable<Mutation> in
                    return .just(.updateIsRequest(true))
                }
            
        case let .cancel(memberId):
            let request: ProfileRequest = .cancelFollow(memberId: memberId)
            
            return self.networkManager.request(Empty.self, request: request)
                .flatMapLatest { _ -> Observable<Mutation> in
                    return .just(.updateIsCancel(true))
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
        case let .follows(follows):
            state.follows = follows
            state.isRequest = false
            state.isCancel = false
        case let .more(follows):
            state.follows += follows
            state.isRequest = false
            state.isCancel = false
        case let .updateIsRequest(isRequest):
            state.isRequest = isRequest
        case let .updateIsCancel(isCancel):
            state.isCancel = isCancel
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        }
        return state
    }
}

extension FollowViewReactor {
    
    private func refresh() -> Observable<Mutation> {
        
        var request: ProfileRequest {
            switch self.entranceType {
            case .following:
                switch self.viewType {
                case .my:
                    return .myFollowing(lastId: nil)
                case .other:
                    return .otherFollowing(memberId: self.memberId ?? "", lastId: nil)
                }
            case .follower:
                switch self.viewType {
                case .my:
                    return .myFollower(lastId: nil)
                case .other:
                    return .otherFollower(memberId: self.memberId ?? "", lastId: nil)
                }
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
    
    private func more(lastId: String) -> Observable<Mutation> {
        
        var request: ProfileRequest {
            switch self.entranceType {
            case .following:
                switch self.viewType {
                case .my:
                    return .myFollowing(lastId: lastId)
                case .other:
                    return .otherFollowing(memberId: self.memberId ?? "", lastId: lastId)
                }
            case .follower:
                switch self.viewType {
                case .my:
                    return .myFollower(lastId: lastId)
                case .other:
                    return .otherFollower(memberId: self.memberId ?? "", lastId: lastId)
                }
            }
        }
        
        switch self.entranceType {
        case .following:
            return self.networkManager.request(FollowingResponse.self, request: request)
                .flatMapLatest { response -> Observable<Mutation> in
                    return .just(.more(response.embedded.followings))
                }
        case .follower:
            return self.networkManager.request(FollowerResponse.self, request: request)
                .flatMapLatest { response -> Observable<Mutation> in
                    return .just(.more(response.embedded.followers))
                }
        }
    }
}

extension FollowViewReactor {
    
    func reactorForProfile(type: ProfileViewReactor.EntranceType, _ memberId: String) -> ProfileViewReactor {
        ProfileViewReactor.init(type: type, memberId: memberId)
    }
    
    func reactorForMainTabBar() -> MainTabBarReactor {
        MainTabBarReactor.init(pushInfo: nil)
    }
}
