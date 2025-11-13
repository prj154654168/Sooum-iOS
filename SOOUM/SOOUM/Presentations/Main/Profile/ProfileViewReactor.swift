//
//  ProfileViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/24.
//

import ReactorKit

import Alamofire

class ProfileViewReactor: Reactor {
    
    struct DisplayStates {
        let cardType: EntranceCardType
        let profileInfo: ProfileInfo?
        let feedCardInfos: [ProfileCardInfo]
        let commCardInfos: [ProfileCardInfo]
    }
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFind(EntranceCardType, String)
        case block
        case follow
        case updateProfile
        case updateCards
        case updateCardType(EntranceCardType)
    }
    
    enum Mutation {
        case profile(ProfileInfo)
        case feedCardInfos([ProfileCardInfo])
        case moreFeedCardInfos([ProfileCardInfo])
        case commentCardInfos([ProfileCardInfo])
        case moreCommentCardInfos([ProfileCardInfo])
        case updateCardType(EntranceCardType)
        case updateIsBlocked(Bool?)
        case updateIsFollowing(Bool?)
        case updateIsRefreshing(Bool)
    }
    
    struct State {
        fileprivate(set) var profileInfo: ProfileInfo?
        fileprivate(set) var feedCardInfos: [ProfileCardInfo]
        fileprivate(set) var commentCardInfos: [ProfileCardInfo]
        fileprivate(set) var cardType: EntranceCardType
        @Pulse fileprivate(set) var isBlocked: Bool?
        @Pulse fileprivate(set) var isFollowing: Bool?
        fileprivate(set) var isRefreshing: Bool
    }
    
    var initialState: State = .init(
        profileInfo: nil,
        feedCardInfos: [],
        commentCardInfos: [],
        cardType: .feed,
        isBlocked: nil,
        isFollowing: nil,
        isRefreshing: false
    )
    
    private let dependencies: AppDIContainerable
    private let userUseCase: UserUseCase
    
    let entranceType: EntranceType
    private let userId: String?
    
    init(dependencies: AppDIContainerable, type entranceType: EntranceType, with userId: String? = nil) {
        self.dependencies = dependencies
        self.userUseCase = dependencies.rootContainer.resolve(UserUseCase.self)
        self.entranceType = entranceType
        self.userId = userId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.userUseCase.profile(userId: self.userId)
                .withUnretained(self)
                .flatMapLatest { object, profileInfo -> Observable<Mutation> in
                    
                    if object.entranceType == .other {
                        
                        return .concat([
                            .just(.profile(profileInfo)),
                            object.userUseCase.feedCards(userId: profileInfo.userId, lastId: nil)
                                .map(Mutation.feedCardInfos)
                        ])
                    } else {
                        
                        return .concat([
                            .just(.profile(profileInfo)),
                            object.userUseCase.feedCards(userId: profileInfo.userId, lastId: nil)
                                .map(Mutation.feedCardInfos),
                            object.userUseCase.myCommentCards(lastId: nil)
                                .map(Mutation.commentCardInfos)
                        ])
                    }
                }
            
        case .refresh:
            
            return self.userUseCase.profile(userId: self.userId)
                .withUnretained(self)
                .flatMapLatest { object, profileInfo -> Observable<Mutation> in
                    
                    if object.currentState.cardType == .feed {
                        
                        return .concat([
                            .just(.updateIsRefreshing(true)),
                            .just(.profile(profileInfo))
                            .catch(self.catchClosure),
                            object.userUseCase.feedCards(userId: profileInfo.userId, lastId: nil)
                                .map(Mutation.feedCardInfos)
                                .catch(self.catchClosure),
                            .just(.updateIsRefreshing(false))
                        ])
                    } else {
                        
                        return .concat([
                            .just(.updateIsRefreshing(true)),
                            .just(.profile(profileInfo))
                                .catch(self.catchClosure),
                            object.userUseCase.myCommentCards(lastId: nil)
                                .map(Mutation.commentCardInfos)
                                .catch(self.catchClosure),
                            .just(.updateIsRefreshing(false))
                        ])
                    }
                }
                .catch(self.catchClosure)
        case let .moreFind(cardType, lastId):
            
            guard let userId = self.currentState.profileInfo?.userId else { return .empty() }
            
            if cardType == .feed {
                
                return self.userUseCase.feedCards(userId: userId, lastId: lastId)
                    .map(Mutation.moreFeedCardInfos)
            } else {
                
                return self.userUseCase.myCommentCards(lastId: lastId)
                    .map(Mutation.moreCommentCardInfos)
            }
        case .updateProfile:
            
            return self.userUseCase.profile(userId: self.userId)
                .map(Mutation.profile)
        case .updateCards:
            
            if self.entranceType == .other, let userId = self.currentState.profileInfo?.userId {
                
                return .concat([
                    self.userUseCase.profile(userId: userId)
                        .map(Mutation.profile),
                    self.userUseCase.feedCards(userId: userId, lastId: nil)
                            .map(Mutation.feedCardInfos)
                ])
            }
            
            return .empty()
        case let .updateCardType(cardType):
            
            return .just(.updateCardType(cardType))
        case .block:
            
            guard let userId = self.currentState.profileInfo?.userId,
                  let isBlocked = self.currentState.profileInfo?.isBlocked
            else { return .empty() }
            
            return .concat([
                .just(.updateIsBlocked(nil)),
                self.userUseCase.updateBlocked(id: userId, isBlocked: !isBlocked)
                    .map(Mutation.updateIsBlocked)
            ])
        case .follow:
            
            guard let userId = self.currentState.profileInfo?.userId,
                  let isFollowing = self.currentState.profileInfo?.isAlreadyFollowing
            else { return .empty() }
            
            return .concat([
                .just(.updateIsFollowing(nil)),
                self.userUseCase.updateFollowing(userId: userId, isFollow: !isFollowing)
                    .map(Mutation.updateIsFollowing)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .profile(profileInfo):
            newState.profileInfo = profileInfo
        case let .feedCardInfos(feedCardInfos):
            newState.feedCardInfos = feedCardInfos
        case let .moreFeedCardInfos(feedCardInfos):
            newState.feedCardInfos += feedCardInfos
        case let .commentCardInfos(commentCardInfos):
            newState.commentCardInfos = commentCardInfos
        case let .moreCommentCardInfos(commentCardInfos):
            newState.commentCardInfos += commentCardInfos
        case let .updateCardType(cardType):
            newState.cardType = cardType
        case let .updateIsBlocked(isBlocked):
            newState.isBlocked = isBlocked
        case let .updateIsFollowing(isFollowing):
            newState.isFollowing = isFollowing
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        }
        return newState
    }
}

extension ProfileViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in .just(.updateIsRefreshing(false)) }
    }
    
    func canUpdateCells(
        prev prevDisplayState: DisplayStates,
        curr currDisplayState: DisplayStates
    ) -> Bool {
        return prevDisplayState.cardType == currDisplayState.cardType &&
            prevDisplayState.profileInfo == currDisplayState.profileInfo &&
            prevDisplayState.feedCardInfos == currDisplayState.feedCardInfos &&
            prevDisplayState.commCardInfos == currDisplayState.commCardInfos
    }
}

extension ProfileViewReactor {
    
    func reactorForSettings() -> SettingsViewReactor {
        SettingsViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForUpdate(with profileInfo: ProfileInfo) -> UpdateProfileViewReactor {
        UpdateProfileViewReactor(dependencies: self.dependencies, with: profileInfo)
    }
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor(
            dependencies: self.dependencies,
            self.currentState.cardType,
            type: .navi,
            with: selectedId
        )
    }
    
    func reactorForFollow(
        type entranceType: FollowViewReactor.EntranceType,
        view viewType: FollowViewReactor.ViewType,
        nickname: String,
        with userId: String
    ) -> FollowViewReactor {
        FollowViewReactor(
            dependencies: self.dependencies,
            type: entranceType,
            view: viewType,
            nickname: nickname,
            with: userId
        )
    }
}

extension ProfileViewReactor {
    
    enum EntranceType {
        case my
        case myWithNavi
        case other
    }
}
