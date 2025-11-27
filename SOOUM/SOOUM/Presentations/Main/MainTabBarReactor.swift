//
//  MainTabBarReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import ReactorKit


class MainTabBarReactor: Reactor {
    
    enum EntranceType {
        /// 푸시 알림(알림 화면)으로 진입할 경우
        case pushToNotification
        /// 푸시 알림(피드 상세 화면)으로 진입할 경우
        case pushToFeedDetail
        /// 푸시 알림(댓글 카드 상세 화면)으로 진입할 경우
        case pushToCommentDetail
        /// 푸시 알림(피드 상세 화면 + 태그 탭)으로 진입할 경우
        case pushToTagDetail
        /// 푸시 알림(내 팔로우 화면 + 팔로우 탭)으로 진입할 경우
        case pushToFollow
        /// 푸시 알림(런치 화면)으로 진입할 경우
        case pushToLaunchScreen
        /// 일반적인 경우
        case none
    }

    enum Action: Equatable {
        case requestLocationPermission
        case judgeEntrance
        case postingPermission
        case resetCouldPosting
        case resetEntrance
    }
    
    enum Mutation {
        case updateEntrance(ProfileInfo)
        case updatePostingPermission(PostingPermission?)
        case resetCouldPosting
        case resetEntrance
    }
    
    struct State {
        fileprivate(set) var entranceType: EntranceType
        fileprivate(set) var couldPosting: PostingPermission?
        @Pulse fileprivate(set) var profileInfo: ProfileInfo?
    }
    
    var initialState: State
    
    var pushInfo: PushNotificationInfo?
    
    private let dependencies: AppDIContainerable
    private let userUseCase: UserUseCase
    private let notificationUseCase: NotificationUseCase
    private let settingsUseCase: SettingsUseCase
    
    init(dependencies: AppDIContainerable, pushInfo: PushNotificationInfo? = nil) {
        self.dependencies = dependencies
        self.userUseCase = dependencies.rootContainer.resolve(UserUseCase.self)
        self.notificationUseCase = dependencies.rootContainer.resolve(NotificationUseCase.self)
        self.settingsUseCase = dependencies.rootContainer.resolve(SettingsUseCase.self)
        
        var willNavigate: EntranceType {
            switch pushInfo?.notificationType {
            case .feedLike:                   return .pushToFeedDetail
            case .commentLike, .commentWrite:  return .pushToCommentDetail
            case .blocked, .deleted:          return .pushToNotification
            case .tagUsage:                   return .pushToTagDetail
            case .follow:                     return .pushToFollow
            case .transferSuccess:             return .pushToLaunchScreen
            default:                          return .none
            }
        }
        self.pushInfo = pushInfo
        
        self.initialState = .init(
            entranceType: willNavigate,
            couldPosting: nil,
            profileInfo: nil
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .requestLocationPermission:
            
            if self.settingsUseCase.checkLocationAuthStatus() == .notDetermined {
                self.settingsUseCase.requestLocationPermission()
            }
            
            return .empty()
        case .judgeEntrance:
            
            if let pushInfo = self.pushInfo {
                
                return .concat([
                    self.userUseCase.profile(userId: nil)
                        .flatMapLatest { profileInfo -> Observable<Mutation> in
                            
                            return self.notificationUseCase.requestRead(
                                notificationId: pushInfo.notificationId ?? ""
                            )
                                .map { _ in .updateEntrance(profileInfo) }
                        },
                    self.settingsUseCase.switchNotification(on: true)
                        .flatMapLatest { _ -> Observable<Mutation> in .empty() }
                ])
            } else {
                
                return self.settingsUseCase.switchNotification(on: true)
                    .flatMapLatest { _ -> Observable<Mutation> in .empty() }
            }
        case .postingPermission:
            
            return self.userUseCase.postingPermission()
                .map(Mutation.updatePostingPermission)
        case .resetCouldPosting:
            
            return .just(.resetCouldPosting)
        case .resetEntrance:
            
            return .just(.resetEntrance)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateEntrance(profileInfo):
            newState.profileInfo = profileInfo
        case let .updatePostingPermission(couldPosting):
            newState.couldPosting = couldPosting
        case .resetCouldPosting:
            newState.couldPosting = nil
        case .resetEntrance:
            newState.entranceType = .none
            newState.profileInfo = nil
            self.pushInfo = nil
        }
        return newState
    }
}

extension MainTabBarReactor {
    
    func reactorForHome() -> HomeViewReactor {
        HomeViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForWriteCard() -> WriteCardViewReactor {
        WriteCardViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForTags() -> TagViewReactor {
        TagViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForProfile() -> ProfileViewReactor {
        ProfileViewReactor(dependencies: self.dependencies, type: .myWithNavi)
    }
    
    func reactorForNoti() -> NotificationViewReactor {
        NotificationViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForDetail(_ targetCardId: String, type: EntranceCardType) -> DetailViewReactor {
        DetailViewReactor(dependencies: self.dependencies, type, type: .push, with: targetCardId)
    }
    
    func reactorForFollow(nickname: String, with userId: String) -> FollowViewReactor {
        FollowViewReactor(
            dependencies: self.dependencies,
            type: .follower,
            view: .my,
            nickname: nickname,
            with: userId
        )
    }
    
    func reactorForLaunchScreen() -> LaunchScreenViewReactor {
        LaunchScreenViewReactor(dependencies: self.dependencies, pushInfo: self.pushInfo)
    }
}
