//
//  SettingsViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit

import Alamofire


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
    
    let provider: ManagerProviderType
    
    private let disposeBag = DisposeBag()
    
    init(provider: ManagerProviderType) {
        self.provider = provider
        
        self.initialState = .init(
            banEndAt: nil,
            notificationStatus: provider.pushManager.notificationStatus,
            isProcessing: false
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.provider.networkManager.request(SettingsResponse.self, request: SettingsRequest.activate)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.updateBanEndAt(response.banEndAt))
                    }
                    .catch(self.catchClosure),
                self.provider.networkManager.request(
                    NotificationAllowResponse.self,
                    request: SettingsRequest.notificationAllow(isAllowNotify: nil)
                )
                .flatMapLatest { response -> Observable<Mutation> in
                    return .just(.updateNotificationStatus(response.isAllowNotify))
                }
                .catch(self.catchClosure),
                .just(.updateIsProcessing(false))
            ])
        case let .updateNotificationStatus(state):
            return self.provider.networkManager.request(
                Empty.self,
                request: SettingsRequest.notificationAllow(isAllowNotify: state)
            )
            .flatMapLatest { _ -> Observable<Mutation> in
                return .just(.updateNotificationStatus(state))
            }
            .catchAndReturn(.updateNotificationStatus(!state))
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
        CommentHistroyViewReactor(provider: self.provider)
    }
    
    func reactorForTransferIssue() -> IssueMemberTransferViewReactor {
        IssueMemberTransferViewReactor(provider: self.provider)
    }
    
    func reactorForTransferEnter() -> EnterMemberTransferViewReactor {
        EnterMemberTransferViewReactor(provider: self.provider, entranceType: .settings)
    }
    
    func reactorForResign() -> ResignViewReactor {
        ResignViewReactor(provider: self.provider, banEndAt: self.currentState.banEndAt)
    }
    
    func reactorForAnnouncement() -> AnnouncementViewReactor {
        AnnouncementViewReactor(provider: self.provider)
    }
}
