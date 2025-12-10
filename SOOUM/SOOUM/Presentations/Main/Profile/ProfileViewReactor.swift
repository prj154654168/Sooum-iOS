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
        let commentCardInfos: [ProfileCardInfo]
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
    private let fetchUserInfoUseCase: FetchUserInfoUseCase
    private let fetchCardUseCase: FetchCardUseCase
    private let blockUserUseCase: BlockUserUseCase
    private let updateFollowUseCase: UpdateFollowUseCase
    
    
    let entranceType: EntranceType
    private let userId: String?
    
    init(dependencies: AppDIContainerable, type entranceType: EntranceType, with userId: String? = nil) {
        self.dependencies = dependencies
        self.fetchUserInfoUseCase = dependencies.rootContainer.resolve(FetchUserInfoUseCase.self)
        self.fetchCardUseCase = dependencies.rootContainer.resolve(FetchCardUseCase.self)
        self.blockUserUseCase = dependencies.rootContainer.resolve(BlockUserUseCase.self)
        self.updateFollowUseCase = dependencies.rootContainer.resolve(UpdateFollowUseCase.self)
        
        self.entranceType = entranceType
        self.userId = userId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.fetchUserInfoUseCase.userInfo(userId: self.userId)
                .withUnretained(self)
                .flatMapLatest { object, profileInfo -> Observable<Mutation> in
                    
                    if object.entranceType == .other {
                        
                        return .concat([
                            .just(.profile(profileInfo)),
                            object.fetchCardUseCase.writtenFeedCards(userId: profileInfo.userId, lastId: nil)
                                .map(Mutation.feedCardInfos)
                        ])
                    } else {
                        // 사용자 닉네임 업데이트
                        UserDefaults.standard.nickname = profileInfo.nickname
                        
                        return .concat([
                            .just(.profile(profileInfo)),
                            object.fetchCardUseCase.writtenFeedCards(userId: profileInfo.userId, lastId: nil)
                                .map(Mutation.feedCardInfos),
                            object.fetchCardUseCase.writtenCommentCards(lastId: nil)
                                .map(Mutation.commentCardInfos)
                        ])
                    }
                }
            
        case .refresh:
            
            return self.fetchUserInfoUseCase.userInfo(userId: self.userId)
                .withUnretained(self)
                .flatMapLatest { object, profileInfo -> Observable<Mutation> in
                    
                    if object.entranceType == .my {
                        // 사용자 닉네임 업데이트
                        UserDefaults.standard.nickname = profileInfo.nickname
                    }
                    
                    if object.currentState.cardType == .feed {
                        
                        return .concat([
                            .just(.updateIsRefreshing(true)),
                            .just(.profile(profileInfo))
                            .catch(self.catchClosure),
                            object.fetchCardUseCase.writtenFeedCards(userId: profileInfo.userId, lastId: nil)
                                .map(Mutation.feedCardInfos)
                                .catch(self.catchClosure),
                            .just(.updateIsRefreshing(false))
                        ])
                    } else {
                        
                        return .concat([
                            .just(.updateIsRefreshing(true)),
                            .just(.profile(profileInfo))
                                .catch(self.catchClosure),
                            object.fetchCardUseCase.writtenCommentCards(lastId: nil)
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
                
                return self.fetchCardUseCase.writtenFeedCards(userId: userId, lastId: lastId)
                    .map(Mutation.moreFeedCardInfos)
            } else {
                
                return self.fetchCardUseCase.writtenCommentCards(lastId: lastId)
                    .map(Mutation.moreCommentCardInfos)
            }
        case .updateProfile:
            
            return self.fetchUserInfoUseCase.userInfo(userId: self.userId)
                .map { profileInfo -> ProfileInfo in
                    // 사용자 닉네임 업데이트
                    UserDefaults.standard.nickname = profileInfo.nickname
                    
                    return profileInfo
                }
                .map(Mutation.profile)
        case .updateCards:
            
            if self.entranceType == .other, let userId = self.currentState.profileInfo?.userId {
                
                return .concat([
                    self.fetchUserInfoUseCase.userInfo(userId: userId)
                        .map(Mutation.profile),
                    self.fetchCardUseCase.writtenFeedCards(userId: userId, lastId: nil)
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
                self.blockUserUseCase.updateBlocked(userId: userId, isBlocked: !isBlocked)
                    .map(Mutation.updateIsBlocked)
            ])
        case .follow:
            
            guard let userId = self.currentState.profileInfo?.userId,
                  let isFollowing = self.currentState.profileInfo?.isAlreadyFollowing
            else { return .empty() }
            
            return .concat([
                .just(.updateIsFollowing(nil)),
                self.updateFollowUseCase.updateFollowing(userId: userId, isFollow: !isFollowing)
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
            prevDisplayState.commentCardInfos == currDisplayState.commentCardInfos
    }
}

extension ProfileViewReactor {
    
    func reactorForSettings() -> SettingsViewReactor {
        SettingsViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForUpdate(
        nickname: String,
        image profileImage: UIImage?,
        imageName profileImageName: String?
    ) -> UpdateProfileViewReactor {
        UpdateProfileViewReactor(
            dependencies: self.dependencies,
            nickname: nickname,
            image: profileImage,
            imageName: profileImageName
        )
    }
    
    func reactorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor(
            dependencies: self.dependencies,
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
        case other
    }
}
