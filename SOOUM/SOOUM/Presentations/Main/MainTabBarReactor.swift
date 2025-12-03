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
        /// 푸시 알림(상세 화면)으로 진입할 경우
        case pushToDetail
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
        @Pulse fileprivate(set) var couldPosting: PostingPermission?
        @Pulse fileprivate(set) var profileInfo: ProfileInfo?
    }
    
    var initialState: State
    
    var pushInfo: PushNotificationInfo?
    
    private let dependencies: AppDIContainerable
    private let fetchUserInfoUseCase: FetchUserInfoUseCase
    private let validateUserUseCase: ValidateUserUseCase
    private let notificationUseCase: NotificationUseCase
    private let updateNotifyUseCase: UpdateNotifyUseCase
    private let locationUseCase: LocationUseCase
    
    init(dependencies: AppDIContainerable, pushInfo: PushNotificationInfo? = nil) {
        self.dependencies = dependencies
        self.fetchUserInfoUseCase = dependencies.rootContainer.resolve(FetchUserInfoUseCase.self)
        self.validateUserUseCase = dependencies.rootContainer.resolve(ValidateUserUseCase.self)
        self.notificationUseCase = dependencies.rootContainer.resolve(NotificationUseCase.self)
        self.updateNotifyUseCase = dependencies.rootContainer.resolve(UpdateNotifyUseCase.self)
        self.locationUseCase = dependencies.rootContainer.resolve(LocationUseCase.self)
        
        var willNavigate: EntranceType {
            switch pushInfo?.notificationType {
            case .feedLike, .commentLike, .commentWrite:  return .pushToDetail
            case .blocked, .deleted:                     return .pushToNotification
            case .tagUsage:                              return .pushToTagDetail
            case .follow:                                return .pushToFollow
            case .transferSuccess:                        return .pushToLaunchScreen
            default:                                     return .none
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
            
            if self.locationUseCase.checkLocationAuthStatus() == .notDetermined {
                self.locationUseCase.requestLocationPermission()
            }
            
            return self.updateNotifyUseCase.switchNotification(on: true)
                .flatMapLatest { _ -> Observable<Mutation> in .empty() }
        case .judgeEntrance:
            
            guard let pushInfo = self.pushInfo else { return .empty() }
            
            return self.fetchUserInfoUseCase.userInfo(userId: nil)
                .flatMapLatest { profileInfo -> Observable<Mutation> in
                    
                    if let notificationId = pushInfo.notificationId {
                        
                        return self.notificationUseCase.requestRead(notificationId: notificationId)
                            .map { _ in .updateEntrance(profileInfo) }
                    } else {
                        
                        return .just(.updateEntrance(profileInfo))
                    }
                }
        case .postingPermission:
            
            return self.validateUserUseCase.postingPermission()
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
        ProfileViewReactor(dependencies: self.dependencies, type: .my)
    }
    
    func reactorForNoti() -> NotificationViewReactor {
        NotificationViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForDetail(_ targetCardId: String) -> DetailViewReactor {
        DetailViewReactor(dependencies: self.dependencies, with: targetCardId)
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
