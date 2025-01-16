//
//  NotificationViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import ReactorKit

import Alamofire


class NotificationViewReactor: Reactor {
    
    enum EntranceType {
        case total
        case comment
        case like
    }
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFind(withoutReadLastId: String?, readLastId: String?)
        case requestRead(String)
    }
    
    enum Mutation {
        case notificationsWithoutRead([CommentHistoryInNoti])
        case notifications([CommentHistoryInNoti])
        case moreWithoutRead([CommentHistoryInNoti])
        case more([CommentHistoryInNoti])
        case withoutReadNotiscount(String)
        case updateIsProcessing(Bool)
        case updateIsLoading(Bool)
        case updateIsReadCompleted(Bool)
    }
    
    struct State {
        var notificationsWithoutRead: [CommentHistoryInNoti]?
        var notifications: [CommentHistoryInNoti]?
        var withoutReadNotisCount: String
        var isProcessing: Bool
        var isLoading: Bool
        var isReadCompleted: Bool
    }
    
    var initialState: State = .init(
        notificationsWithoutRead: nil,
        notifications: nil,
        withoutReadNotisCount: "0",
        isProcessing: false,
        isLoading: false,
        isReadCompleted: false
    )
    
    private let entranceType: EntranceType
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType, _ entranceType: EntranceType) {
        self.provider = provider
        self.entranceType = entranceType
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            let combined = Observable.concat([
                self.withoutReadNotisCount(),
                self.notifications(with: false),
                self.notifications(with: true)
            ])
                .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                combined,
                .just(.updateIsProcessing(false))
            ])
            
        case .refresh:
            
            let combined = Observable.concat([
                self.withoutReadNotisCount(),
                self.notifications(with: false),
                self.notifications(with: true)
            ])
                .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            
            return .concat([
                .just(.updateIsLoading(true)),
                combined,
                .just(.updateIsLoading(false))
            ])
            
        case let .moreFind(withoutReadLastId, readLastId):
            
            let combined = Observable.concat([
                self.withoutReadNotisCount(),
                self.moreNotifications(with: false, lastId: withoutReadLastId),
                self.moreNotifications(with: true, lastId: readLastId)
            ])
                .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                combined,
                .just(.updateIsProcessing(false))
            ])
            
        case let .requestRead(selectedId):
            let request: NotificationRequest = .requestRead(notificationId: selectedId)
            return self.provider.networkManager.request(Empty.self, request: request)
                .map { _ in .updateIsReadCompleted(true) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .notificationsWithoutRead(notificationsWithoutRead):
            state.notificationsWithoutRead = notificationsWithoutRead
        case let .notifications(notifications):
            state.notifications = notifications
        case let .moreWithoutRead(notificationsWithoutRead):
            state.notificationsWithoutRead? += notificationsWithoutRead
        case let .more(notifications):
            state.notifications? += notifications
        case let .withoutReadNotiscount(withoutReadNotisCount):
            state.withoutReadNotisCount = withoutReadNotisCount
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        case let .updateIsReadCompleted(isReadCompleted):
            state.isReadCompleted = isReadCompleted
        }
        return state
    }
}

extension NotificationViewReactor {
    
    private func notifications(with isRead: Bool) -> Observable<Mutation> {
        
        var request: NotificationRequest {
            switch self.entranceType {
            case .total:
                return isRead ? .totalRead(lastId: nil) : .totalWithoutRead(lastId: nil)
            case .comment:
                return isRead ? .commentRead(lastId: nil) : .commentWithoutRead(lastId: nil)
            case .like:
                return isRead ? .likeRead(lastId: nil) : .likeWithoutRead(lastId: nil)
            }
        }
        
        return self.provider.networkManager.request(CommentHistoryInNotiResponse.self, request: request)
            .map(\.commentHistoryInNotis)
            .map(isRead ? Mutation.notifications : Mutation.notificationsWithoutRead)
            .catch(self.catchClosure)
    }
    
    private func moreNotifications(with isRead: Bool, lastId: String?) -> Observable<Mutation> {
        
        guard let lastId = lastId else { return .just(.more([])) }
        
        var request: NotificationRequest {
            switch self.entranceType {
            case .total:
                return isRead ? .totalRead(lastId: lastId) : .totalWithoutRead(lastId: lastId)
            case .comment:
                return isRead ? .commentRead(lastId: lastId) : .commentWithoutRead(lastId: lastId)
            case .like:
                return isRead ? .likeRead(lastId: lastId) : .likeWithoutRead(lastId: lastId)
            }
        }
        
        return self.provider.networkManager.request(CommentHistoryInNotiResponse.self, request: request)
            .map(\.commentHistoryInNotis)
            .map(isRead ? Mutation.more : Mutation.moreWithoutRead)
            .catch(self.catchClosure)
    }
    
    private func withoutReadNotisCount() -> Observable<Mutation> {
        
        var request: NotificationRequest {
            switch self.entranceType {
            case .total:
                return .totalWithoutReadCount
            case .comment:
                return .commentWithoutReadCount
            case .like:
                return .likeWihoutReadCount
            }
        }
        
        return self.provider.networkManager.request(WithoutReadNotisCountResponse.self, request: request)
            .map(\.unreadCnt)
            .map(Mutation.withoutReadNotiscount)
    }
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.updateIsProcessing(false))
            ])
        }
    }
}
