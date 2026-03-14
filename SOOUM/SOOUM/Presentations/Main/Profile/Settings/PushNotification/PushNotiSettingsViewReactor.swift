//
//  PushNotiSettingsViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 3/8/26.
//

import ReactorKit

final class PushNotiSettingsViewReactor: Reactor {
    
    enum Action {
        case updatePushNotiStatus(PushNotiStatusInfo)
    }
    
    enum Mutation {
        case updatePushNotiStatus(PushNotiStatusInfo)
    }
    
    struct State {
        fileprivate(set) var pushNotistatus: PushNotiStatusInfo
    }
    
    var initialState: State
    
    private let dependencies: AppDIContainerable
    private let updateNotifyUseCase: UpdateNotifyUseCase
    
    init(dependencies: AppDIContainerable, with pushNotiStatus: PushNotiStatusInfo) {
        self.dependencies = dependencies
        self.updateNotifyUseCase = dependencies.rootContainer.resolve(UpdateNotifyUseCase.self)
        
        self.initialState = .init(pushNotistatus: pushNotiStatus)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updatePushNotiStatus(pushNotiStatus):
            
            return self.updateNotifyUseCase.updateNotify(
                commentCardNotify: pushNotiStatus.commentCardNotify,
                cardLikeNotify: pushNotiStatus.cardLikeNotify,
                followUserCardNotify: pushNotiStatus.followUserCardNotify,
                newFollowerNotify: pushNotiStatus.newFollowerNotify,
                cardNewCommentNotify: pushNotiStatus.cardNewCommentNotify,
                recommendedContentNotify: pushNotiStatus.recommendedContentNotify,
                favoriteTagNotify: pushNotiStatus.favoriteTagNotify,
                serviceUpdateNotify: pushNotiStatus.serviceUpdateNotify,
                policyViolationNotify: pushNotiStatus.policyViolationNotify
            )
            .withUnretained(self)
            .map { object, isUpdated in
                isUpdated ? pushNotiStatus : object.currentState.pushNotistatus
            }
            .map(Mutation.updatePushNotiStatus)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .updatePushNotiStatus(pushNotiStatus):
            newState.pushNotistatus = pushNotiStatus
        }
        return newState
    }
}
