//
//  FollowViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit

import Alamofire

class FollowViewReactor: Reactor {
    
    struct DisplayStates {
        let followType: EntranceType
        let followers: [FollowInfo]
        let followings: [FollowInfo]
    }
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFind(type: EntranceType, lastId: String)
        case updateFollowType(EntranceType)
        case updateFollow(String, Bool)
    }
    
    enum Mutation {
        case followers([FollowInfo])
        case followings([FollowInfo])
        case moreFollowers([FollowInfo])
        case moreFollowings([FollowInfo])
        case updateFollowType(EntranceType)
        case updateIsUpdated(Bool?)
        case updateIsRefreshing(Bool)
    }
    
    struct State {
        fileprivate(set) var followers: [FollowInfo]
        fileprivate(set) var followings: [FollowInfo]
        fileprivate(set) var followType: EntranceType
        @Pulse fileprivate(set) var isUpdated: Bool?
        fileprivate(set) var isRefreshing: Bool
    }
    
    var initialState: State = .init(
        followers: [],
        followings: [],
        followType: .follower,
        isUpdated: nil,
        isRefreshing: false
    )
    
    private let dependencies: AppDIContainerable
    private let fetchFollowUseCase: FetchFollowUseCase
    private let updateFollowUseCase: UpdateFollowUseCase
    
    let entranceType: EntranceType
    let viewType: ViewType
    let nickname: String
    private let userId: String
    
    init(
        dependencies: AppDIContainerable,
        type entranceType: EntranceType,
        view viewType: ViewType,
        nickname: String,
        with userId: String
    ) {
        self.dependencies = dependencies
        self.fetchFollowUseCase = dependencies.rootContainer.resolve(FetchFollowUseCase.self)
        self.updateFollowUseCase = dependencies.rootContainer.resolve(UpdateFollowUseCase.self)
        
        self.entranceType = entranceType
        self.viewType = viewType
        self.nickname = nickname
        self.userId = userId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                self.followers(with: nil)
                    .catchAndReturn(.followers([])),
                self.followings(with: nil)
                    .catchAndReturn(.followings([]))
            ])
        case .refresh:
            
            let emit = self.currentState.followType == .follower ?
                self.followers(with: nil)
                    .catch { _ in
                        return .concat([
                            .just(.updateIsRefreshing(false)),
                            .just(.followers([]))
                        ])
                    } :
                self.followings(with: nil)
                    .catch { _ in
                        return .concat([
                            .just(.updateIsRefreshing(false)),
                            .just(.followings([]))
                        ])
                    }

            return .concat([
                .just(.updateIsRefreshing(true)),
                emit,
                .just(.updateIsRefreshing(false))
            ])
        case let .moreFind(type, lastId):
            
            let emit = type == .follower ? self.followers(with: lastId) : self.followings(with: lastId)
            return emit
        case let .updateFollowType(followType):
            
            return .just(.updateFollowType(followType))
        case let .updateFollow(userId, isFollow):
            
            return .concat([
                .just(.updateIsUpdated(nil)),
                self.updateFollowUseCase.updateFollowing(userId: userId, isFollow: isFollow)
                    .map(Mutation.updateIsUpdated)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .followers(followers):
            newState.followers = followers
        case let .followings(followings):
            newState.followings = followings
        case let .moreFollowers(followers):
            newState.followers += followers
        case let .moreFollowings(followings):
            newState.followings += followings
        case let .updateFollowType(followType):
            newState.followType = followType
        case let .updateIsUpdated(isUpdated):
            newState.isUpdated = isUpdated
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        }
        return newState
    }
}

private extension FollowViewReactor {
     
    func followers(with lastId: String?) -> Observable<Mutation> {
        
        return self.fetchFollowUseCase.followers(userId: self.userId, lastId: lastId)
            .map { lastId == nil ? .followers($0) : .moreFollowers($0) }
    }
    
    func followings(with lastId: String?) -> Observable<Mutation> {
        
        return self.fetchFollowUseCase.followings(userId: self.userId, lastId: lastId)
            .map { lastId == nil ? .followings($0) : .moreFollowings($0) }
    }
}

extension FollowViewReactor {
    
    func reactorForProfile( _ userId: String) -> ProfileViewReactor {
        ProfileViewReactor(dependencies: self.dependencies, type: .other, with: userId)
    }
}

extension FollowViewReactor {
    
    enum EntranceType {
        case follower
        case following
    }
    
    enum ViewType {
        case my
        case other
    }
}
