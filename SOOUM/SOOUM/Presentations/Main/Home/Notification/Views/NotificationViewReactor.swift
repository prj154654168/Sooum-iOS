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
        case updateIsReadCompleted(Bool)
    }
    
    struct State {
        var notificationsWithoutRead: [CommentHistoryInNoti]
        var notifications: [CommentHistoryInNoti]
        var isProcessing: Bool
        var isReadCompleted: Bool
    }
    
    var initialState: State = .init(
        notificationsWithoutRead: [],
        notifications: [],
        isProcessing: false,
        isReadCompleted: false
    )
    
    private let entranceType: EntranceType
    
    private let networkManager = NetworkManager.shared
    
    init(_ entranceType: EntranceType) {
        self.entranceType = entranceType
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            
            var requestWithoutRead: NotificationRequest {
                switch self.entranceType {
                case .total:
                    return .totalWithoutRead(lastId: nil)
                case .comment:
                    return .commentWithoutRead(lastId: nil)
                case .like:
                    return .likeWithoutRead(id: nil)
                }
            }
            let responseWithoutRead = self.networkManager.request(
                CommentHistoryInNotiResponse.self,
                request: requestWithoutRead
            )
            
            var request: NotificationRequest {
                switch self.entranceType {
                case .total:
                    return .totalRead(lastId: nil)
                case .comment:
                    return .commentRead(lastId: nil)
                case .like:
                    return .likeRead(lastId: nil)
                }
            }
            let response = self.networkManager.request(
                CommentHistoryInNotiResponse.self,
                request: request
            )
            
            return .concat([
                .just(.updateIsProcessing(true)),
                responseWithoutRead
                    .map(\.commentHistoryInNotis)
                    .map(Mutation.notificationsWithoutRead)
                    .catch(self.catchClosure),
                response
                    .map(\.commentHistoryInNotis)
                    .map(Mutation.notifications)
                    .catch(self.catchClosure),
                .just(.updateIsProcessing(false))
            ])
        case let .moreFind(lastId):
            
            var requestWithoutRead: NotificationRequest {
                switch self.entranceType {
                case .total:
                    return .totalWithoutRead(lastId: lastId)
                case .comment:
                    return .commentWithoutRead(lastId: lastId)
                case .like:
                    return .likeWithoutRead(id: lastId)
                }
            }
            let responseWithoutRead = self.networkManager.request(
                CommentHistoryInNotiResponse.self,
                request: requestWithoutRead
            )
            
            var request: NotificationRequest {
                switch self.entranceType {
                case .total:
                    return .totalRead(lastId: lastId)
                case .comment:
                    return .commentRead(lastId: lastId)
                case .like:
                    return .likeRead(lastId: lastId)
                }
            }
            let response = self.networkManager.request(
                CommentHistoryInNotiResponse.self,
                request: request
            )
            
            return .concat([
                responseWithoutRead
                    .map(\.commentHistoryInNotis)
                    .map(Mutation.notificationsWithoutRead),
                response
                    .map(\.commentHistoryInNotis)
                    .map(Mutation.notifications)
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
        case let .updateIsReadCompleted(isReadCompleted):
            state.isReadCompleted = isReadCompleted
        }
        return state
    }
}

extension NotificationViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.updateIsProcessing(false))
            ])
        }
    }
}
