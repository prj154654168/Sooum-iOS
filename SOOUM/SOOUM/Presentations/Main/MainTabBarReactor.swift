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
        case pushForNoti
        /// 푸시 알림(상세보기 화면)으로 진입할 경우
        case pushForDetail
        /// 네비게이션 푸시가 필요 없을 때
        case none
    }

    enum Action: Equatable {
        case requestLocationPermission
        case judgeEntrance
        case postingPermission
        case reset
    }
    
    enum Mutation {
        case updateEntrance
        case updatePostingPermission(PostingPermission?)
        case reset
    }
    
    struct State {
        fileprivate(set) var entranceType: EntranceType
        fileprivate(set) var couldPosting: PostingPermission?
    }
    
    private let disposeBag = DisposeBag()
    
    var initialState: State
    
    private let willNavigate: EntranceType
    let pushInfo: NotificationInfo?
    
    private let dependencies: AppDIContainerable
    private let userUseCase: UserUseCase
    private let settingsUseCase: SettingsUseCase
    
    init(dependencies: AppDIContainerable, pushInfo: NotificationInfo? = nil) {
        self.dependencies = dependencies
        self.userUseCase = dependencies.rootContainer.resolve(UserUseCase.self)
        self.settingsUseCase = dependencies.rootContainer.resolve(SettingsUseCase.self)
        
        var willNavigate: EntranceType {
            // switch pushInfo?.notificationType {
            // case .feedLike, .commentLike, .commentWrite:
            //     return .pushForDetail
            // case .blocked, .delete:
            //     return .pushForNoti
            // default:
            //     return .none
            // }
            return .none
        }
        self.willNavigate = willNavigate
        self.pushInfo = pushInfo
        
        self.initialState = .init(
            entranceType: .none,
            couldPosting: nil
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
            
            return .concat([
                .just(.updateEntrance),
                self.settingsUseCase.switchNotification(on: true)
                    .flatMapLatest { _ -> Observable<Mutation> in .empty() }
            ])
        case .postingPermission:
            
            return self.userUseCase.postingPermission()
                .map(Mutation.updatePostingPermission)
        case .reset:
            
            return .just(.reset)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateEntrance:
            newState.entranceType = self.willNavigate
        case let .updatePostingPermission(couldPosting):
            newState.couldPosting = couldPosting
        case .reset:
            newState.couldPosting = nil
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
    
    // func reactorForTags() -> TagsViewReactor {
    //     TagsViewReactor(provider: self.provider)
    // }
    
    func reactorForProfile() -> ProfileViewReactor {
        ProfileViewReactor(dependencies: self.dependencies, type: .myWithNavi)
    }
    
    func reactorForNoti() -> NotificationViewReactor {
        NotificationViewReactor(dependencies: self.dependencies)
    }
    
    // func reactorForDetail(_ targetCardId: String) -> DetailViewReactor {
    //     DetailViewReactor(provider: self.provider, type: .push, targetCardId)
    // }
}
