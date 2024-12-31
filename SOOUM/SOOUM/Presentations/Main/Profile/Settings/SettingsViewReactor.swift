//
//  SettingsViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit


class SettingsViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case updateNotificationStatus(Bool)
    }
    
    enum Mutation {
        case updateBanEndAt(Date?)
        case updateNotificationStatus(Bool)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var banEndAt: Date?
        var notificationStatus: Bool
        var isProcessing: Bool
    }
    
    var initialState: State
    
    private let networkManager = NetworkManager.shared
    private let pushManager = PushManager.shared
    
    private let disposeBag = DisposeBag()
    
    init() {
        
        self.initialState = .init(
            banEndAt: nil,
            notificationStatus: self.pushManager.notificationStatus,
            isProcessing: false
        )
        
        self.subscribe()
    }
    
    private func subscribe() {

        self.pushManager.rx.observe(\.notificationStatus)
            .map(Action.updateNotificationStatus)
            .bind(to: self.action)
            .disposed(by: self.disposeBag)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.networkManager.request(SettingsResponse.self, request: SettingsRequest.activate)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.updateBanEndAt(response.banEndAt))
                    }
                    .catch(self.catchClosure),
                .just(.updateIsProcessing(false))
            ])
        case let .updateNotificationStatus(state):
            return .just(.updateNotificationStatus(state))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .updateBanEndAt(banEndAt):
            state.banEndAt = banEndAt
        case let .updateNotificationStatus(notificationStatus):
            state.notificationStatus = notificationStatus
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        }
        return state
    }
}

extension SettingsViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.updateIsProcessing(false))
            ])
        }
    }
}

extension SettingsViewReactor {
    
    func reactorForCommentHistory() -> CommentHistroyViewReactor {
        CommentHistroyViewReactor.init()
    }
    
    func reactorForTransferIssue() -> IssueMemberTransferViewReactor {
        IssueMemberTransferViewReactor.init()
    }
    
    func reactorForTransferEnter() -> EnterMemberTransferViewReactor {
        EnterMemberTransferViewReactor.init(entranceType: .settings)
    }
    
    func reactorForResign() -> ResignViewReactor {
        ResignViewReactor.init(banEndAt: self.currentState.banEndAt)
    }
    
    func reactorForAnnouncement() -> AnnouncementViewReactor {
        AnnouncementViewReactor.init()
    }
}
