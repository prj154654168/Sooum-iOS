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
        case updateBlockUserInfos([BlockUserInfo])
    }
    
    enum Mutation {
        case blockUserInfos([BlockUserInfo])
        case more([BlockUserInfo])
        case updateIsCanceled((isCanceled: Bool, userId: String)?)
        case updateIsRefreshing(Bool)
    }
    
    struct State {
        fileprivate(set) var blockUserInfos: [BlockUserInfo]
        fileprivate(set) var isCanceledWithId: (isCanceled: Bool, userId: String)?
        fileprivate(set) var isRefreshing: Bool
    }
    
    var initialState: State = .init(
        blockUserInfos: [],
        isCanceledWithId: nil,
        isRefreshing: false
    )
    
    private let dependencies: AppDIContainerable
    private let fetchBlockUserUseCase: FetchBlockUserUseCase
    private let blockUserUseCase: BlockUserUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.fetchBlockUserUseCase = dependencies.rootContainer.resolve(FetchBlockUserUseCase.self)
        self.blockUserUseCase = dependencies.rootContainer.resolve(BlockUserUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.fetchBlockUserUseCase.blockUsers(lastId: nil)
                .map(Mutation.blockUserInfos)
        case .refresh:
            
            return .concat([
                .just(.updateIsRefreshing(true)),
                self.fetchBlockUserUseCase.blockUsers(lastId: nil)
                    .map(Mutation.blockUserInfos),
                .just(.updateIsRefreshing(false))
            ])
        case let .moreFind(lastId):
            
            return self.fetchBlockUserUseCase.blockUsers(lastId: lastId)
                .map(Mutation.more)
        case let .cancelBlock(userId):
            
            return self.blockUserUseCase.updateBlocked(userId: userId, isBlocked: false)
                .map { ($0, userId) }
                .map(Mutation.updateIsCanceled)
        case let .updateBlockUserInfos(blockUserInfos):
            
            return .just(.blockUserInfos(blockUserInfos))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .blockUserInfos(blockUserInfos):
            newState.blockUserInfos = blockUserInfos
        case let .more(blockUserInfos):
            newState.blockUserInfos += blockUserInfos
        case let .updateIsCanceled(isCanceledWithId):
            newState.isCanceledWithId = isCanceledWithId
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        }
        return newState
    }
}

extension BlockUsersViewReactor {
    
    func canUpdateCanceledWithId(
        prev prevIsCanceledWithId: (isCanceled: Bool, userId: String)?,
        curr currIsCanceledWithId: (isCanceled: Bool, userId: String)?
    ) -> Bool {
        return prevIsCanceledWithId?.isCanceled == currIsCanceledWithId?.isCanceled &&
            prevIsCanceledWithId?.userId == currIsCanceledWithId?.userId
    }
}

extension BlockUsersViewReactor {
    
    func reactorForProfile(_ userId: String) -> ProfileViewReactor {
        ProfileViewReactor(dependencies: self.dependencies, type: .other, with: userId)
    }
}
