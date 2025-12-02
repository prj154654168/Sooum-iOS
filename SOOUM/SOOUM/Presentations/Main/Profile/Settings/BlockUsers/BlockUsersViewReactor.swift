//
//  BlockUsersViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import ReactorKit

class BlockUsersViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFind(lastId: String)
        case cancelBlock(userId: String)
    }
    
    enum Mutation {
        case blockUserInfos([BlockUserInfo])
        case more([BlockUserInfo])
        case updateIsCanceled(Bool?)
        case updateIsRefreshing(Bool)
    }
    
    struct State {
        fileprivate(set) var blockUserInfos: [BlockUserInfo]
        fileprivate(set) var isCanceled: Bool?
        fileprivate(set) var isRefreshing: Bool
    }
    
    var initialState: State = .init(
        blockUserInfos: [],
        isCanceled: nil,
        isRefreshing: false
    )
    
    private let dependencies: AppDIContainerable
    private let settingsUseCase: SettingsUseCase
    private let userUseCase: UserUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.settingsUseCase = dependencies.rootContainer.resolve(SettingsUseCase.self)
        self.userUseCase = dependencies.rootContainer.resolve(UserUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.settingsUseCase.blockUsers(lastId: nil)
                .map(Mutation.blockUserInfos)
        case .refresh:
            
            return .concat([
                .just(.updateIsRefreshing(true)),
                self.settingsUseCase.blockUsers(lastId: nil)
                    .map(Mutation.blockUserInfos),
                .just(.updateIsRefreshing(false))
            ])
        case let .moreFind(lastId):
            
            return self.settingsUseCase.blockUsers(lastId: lastId)
                .map(Mutation.more)
        case let .cancelBlock(userId):
            
            return self.userUseCase.updateBlocked(id: userId, isBlocked: false)
                .map(Mutation.updateIsCanceled)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .blockUserInfos(blockUserInfos):
            newState.blockUserInfos = blockUserInfos
        case let .more(blockUserInfos):
            newState.blockUserInfos += blockUserInfos
        case let .updateIsCanceled(isCanceled):
            newState.isCanceled = isCanceled
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        }
        return newState
    }
}

extension BlockUsersViewReactor {
    
    func reactorForProfile(_ userId: String) -> ProfileViewReactor {
        ProfileViewReactor(dependencies: self.dependencies, type: .other, with: userId)
    }
    
    // func reactorForMainTabBar() -> MainTabBarReactor {
    //     MainTabBarReactor(provider: self.provider)
    // }
}
