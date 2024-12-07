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
    }
    
    enum Mutation {
        case updateBanEndAt(Date?)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var banEndAt: Date?
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        banEndAt: nil,
        isProcessing: false
    )
    
    private let networkManager = NetworkManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.networkManager.request(SettingsResponse.self, request: SettingsRequest.activate)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.updateBanEndAt(response.banEndAt))
                    },
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
        EnterMemberTransferViewReactor.init()
    }
    
    func reactorForResign() -> ResignViewReactor {
        ResignViewReactor.init(banEndAt: self.currentState.banEndAt)
    }
    
    func reactorForAnnouncement() -> AnnouncementViewReactor {
        AnnouncementViewReactor.init()
    }
}
