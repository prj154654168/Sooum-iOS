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
        case moreFind(String)
        case requestRead(String)
    }
    
    enum Mutation {
        case notificationsWithoutRead([CommentHistoryInNoti])
        case notifications([CommentHistoryInNoti])
        case moreWithoutRead([CommentHistoryInNoti])
        case more([CommentHistoryInNoti])
        case updateIsProcessing(Bool)
        case updateIsLoading(Bool)
        case updateIsReadCompleted(Bool)
    }
    
    struct State {
        var notificationsWithoutRead: [CommentHistoryInNoti]
        var notifications: [CommentHistoryInNoti]
        var isProcessing: Bool
        var isLoading: Bool
        var isReadCompleted: Bool
    }
    
    var initialState: State = .init(
        notificationsWithoutRead: [],
        notifications: [],
        isProcessing: false,
        isLoading: false,
        isReadCompleted: false
    )
    
    private let entranceType: EntranceType
    
    private let networkManager = NetworkManager.shared
    
    init(_ entranceType: EntranceType) {
        self.entranceType = entranceType
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.notifications(with: false),
                self.notifications(with: true),
                .just(.updateIsProcessing(false))
            ])
        case .refresh:
            
            return .concat([
                .just(.updateIsLoading(true)),
                self.notifications(with: false)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                self.notifications(with: true)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsLoading(false))
            ])
        case let .moreFind(lastId):
            
            return .concat([
                self.moreNotifications(with: false, lastId: lastId)
                    .catch(self.catchClosure),
                self.moreNotifications(with: true, lastId: lastId)
                    .catch(self.catchClosure)
            ])
        case let .requestRead(selectedId):
            let request: NotificationRequest = .requestRead(notificationId: selectedId)
            return self.networkManager.request(Empty.self, request: request)
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
            state.notificationsWithoutRead += notificationsWithoutRead
        case let .more(notifications):
            state.notifications += notifications
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
        
        return self.networkManager.request(CommentHistoryInNotiResponse.self, request: request)
            .map(\.commentHistoryInNotis)
            .map(isRead ? Mutation.notifications : Mutation.notificationsWithoutRead)
            .catch(self.catchClosure)
    }
    
    private func moreNotifications(with isRead: Bool, lastId: String) -> Observable<Mutation> {
        
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
        
        return self.networkManager.request(CommentHistoryInNotiResponse.self, request: request)
            .map(\.commentHistoryInNotis)
            .map(isRead ? Mutation.notifications : Mutation.notificationsWithoutRead)
            .catch(self.catchClosure)
    }
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.updateIsProcessing(false))
            ])
        }
    }
}
