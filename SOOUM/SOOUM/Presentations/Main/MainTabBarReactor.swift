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
        case judgeEntrance
        case updateNotificationStatus(Bool)
    }
    
    enum Mutation {
        case updateEntrance
        case updateNotificationStatus(Bool)
    }
    
    struct State {
        var entranceType: EntranceType
        var notificationStatus: Bool
    }
    
    private let disposeBag = DisposeBag()
    
    var initialState: State
    
    private let willNavigate: EntranceType
    let pushInfo: NotificationInfo?
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType, pushInfo: NotificationInfo? = nil) {
        self.provider = provider
        
        var willNavigate: EntranceType {
            switch pushInfo?.notificationType {
            case .feedLike, .commentLike, .commentWrite:
                return .pushForDetail
            case .blocked, .delete:
                return .pushForNoti
            default:
                return .none
            }
        }
        self.willNavigate = willNavigate
        self.pushInfo = pushInfo
        
        self.initialState = .init(
            entranceType: .none,
            notificationStatus: provider.pushManager.notificationStatus
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .judgeEntrance:
            return .concat([
                .just(.updateEntrance),
                self.provider.pushManager.switchNotification(on: true)
                    .flatMapLatest { error -> Observable<Mutation> in .empty() }
            ])
        case let .updateNotificationStatus(status):
            return .just(.updateNotificationStatus(status))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .updateEntrance:
            state.entranceType = self.willNavigate
        case let .updateNotificationStatus(status):
            state.notificationStatus = status
        }
        return state
    }
}

extension MainTabBarReactor {
    
    private func subscribe() {
        
        (self.provider.pushManager as? PushManager)?.rx.observe(\.notificationStatus)
            .map(Action.updateNotificationStatus)
            .bind(to: self.action)
            .disposed(by: self.disposeBag)
    }
}

extension MainTabBarReactor {
    
    func reactorForMainHome() -> MainHomeTabBarReactor {
        MainHomeTabBarReactor(provider: self.provider)
    }
    
    func reactorForWriteCard() -> WriteCardViewReactor {
        WriteCardViewReactor(provider: self.provider, type: .card)
    }
    
    func reactorForTags() -> TagsViewReactor {
        TagsViewReactor(provider: self.provider)
    }
    
    func reactorForProfile() -> ProfileViewReactor {
        ProfileViewReactor(provider: self.provider, type: .my, memberId: nil)
    }
    
    func reactorForNoti() -> NotificationTabBarReactor {
        NotificationTabBarReactor(provider: self.provider)
    }
    
    func reactorForDetail(_ targetCardId: String) -> DetailViewReactor {
        DetailViewReactor(provider: self.provider, type: .push, targetCardId)
    }
}
