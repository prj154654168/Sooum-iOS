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
    }
    
    enum Mutation {
        case updateEntrance
    }
    
    struct State {
        var entranceType: EntranceType
    }
    
    var initialState: State = .init(entranceType: .none)
    
    private let willNavigate: EntranceType
    let pushInfo: NotificationInfo?
    
    init(pushInfo: NotificationInfo? = nil) {
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
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .judgeEntrance:
            return .just(.updateEntrance)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .updateEntrance:
            state.entranceType = self.willNavigate
        }
        return state
    }
}

extension MainTabBarReactor {
    
    func reactorForMainHome() -> MainHomeTabBarReactor {
        MainHomeTabBarReactor.init()
    }
    
    func reactorForWriteCard() -> WriteCardViewReactor {
        WriteCardViewReactor(type: .card)
    }
    
    func reactorForProfile() -> ProfileViewReactor {
        ProfileViewReactor(type: .my, memberId: nil)
    }
    
    func reactorForNoti() -> NotificationViewReactor {
        NotificationViewReactor(.total)
    }
    
    func reactorForDetail(_ targetCardId: String) -> DetailViewReactor {
        DetailViewReactor(targetCardId)
    }
}
