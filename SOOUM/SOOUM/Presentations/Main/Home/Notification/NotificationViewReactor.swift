//
//  NotificationViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import ReactorKit

import Alamofire

class NotificationViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case refresh
        case updateDisplayType(DisplayType)
        case moreFind(lastId: String, displayType: DisplayType)
        case requestRead(String)
        case updatePushOrRequestReadInfo(PushOrRequestReadInfo)
    }
    
    enum Mutation {
        case notifications(unreads: [CompositeNotificationInfo], reads: [CompositeNotificationInfo])
        case more(unreads: [CompositeNotificationInfo], reads: [CompositeNotificationInfo])
        case notices([NoticeInfo])
        case moreNotices([NoticeInfo])
        case updateDisplayType(DisplayType)
        case updatePushOrRequestReadInfo((detailType: DetailViewReactor.DetailType, id: String)?)
        case updateIsRefreshing(Bool)
        case updateIsReadSuccess(Bool)
    }
    
    struct State {
        fileprivate(set) var displayType: DisplayType
        fileprivate(set) var notificationsForUnread: [CompositeNotificationInfo]?
        fileprivate(set) var notifications: [CompositeNotificationInfo]?
        fileprivate(set) var notices: [NoticeInfo]?
        fileprivate(set) var pushInfo: (detailType: DetailViewReactor.DetailType, id: String)?
        fileprivate(set) var isRefreshing: Bool
        fileprivate(set) var isReadSuccess: Bool
    }
    
    var initialState: State
    
    private let dependencies: AppDIContainerable
    private let notificationUseCase: NotificationUseCase
    
    init(dependencies: AppDIContainerable, displayType: DisplayType = .activity(.unread)) {
        self.dependencies = dependencies
        self.notificationUseCase = dependencies.rootContainer.resolve(NotificationUseCase.self)
        
        self.initialState = State(
          displayType: displayType,
          notificationsForUnread: nil,
          notifications: nil,
          notices: nil,
          pushInfo: nil,
          isRefreshing: false,
          isReadSuccess: false
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                Observable.zip(
                    self.notificationUseCase.unreadNotifications(lastId: nil),
                    self.notificationUseCase.readNotifications(lastId: nil)
                )
                    .map(Mutation.notifications)
                    .catch(self.catchClosureNotis),
                self.notificationUseCase.notices(lastId: nil, size: 10)
                    .map(Mutation.notices)
                    .catch(self.catchClosureNotices)
            ])
        case .refresh:
            
            switch self.currentState.displayType {
            case .activity:
                return .concat([
                    .just(.updateIsRefreshing(true)),
                    Observable.zip(
                        self.notificationUseCase.unreadNotifications(lastId: nil),
                        self.notificationUseCase.readNotifications(lastId: nil)
                    )
                    .map(Mutation.notifications)
                    .catch(self.catchClosureNotis),
                    .just(.updateIsRefreshing(false))
                ])
                
            case .notice:
                return .concat([
                    .just(.updateIsRefreshing(true)),
                    self.notificationUseCase.notices(lastId: nil, size: 10)
                        .map(Mutation.notices)
                        .catch(self.catchClosureNotices),
                    .just(.updateIsRefreshing(false))
                ])
            }
        case let .updateDisplayType(displayType):
            return .just(.updateDisplayType(displayType))
            
        case let .moreFind(lastId, displayType):
            
            switch displayType {
            case let .activity(activityType):
                return .concat([
                    self.moreNotification(activityType, with: lastId)
                        .catch(self.catchClosureNotisMore)
                ])
            case .notice:
                return .concat([
                    self.notificationUseCase.notices(lastId: lastId, size: 10)
                        .map(Mutation.moreNotices)
                        .catch(self.catchClosureNoticesMore)
                ])
            }
        case let .requestRead(selectedId):
            
            return self.notificationUseCase.requestRead(notificationId: selectedId)
                .map(Mutation.updateIsReadSuccess)
            
        case let .updatePushOrRequestReadInfo(pushOrRequestReadInfo):
            
            /// 읽은 알림 여부 확인
            if pushOrRequestReadInfo.shouldRead {
                
                return self.notificationUseCase.requestRead(notificationId: pushOrRequestReadInfo.notificationId)
                    .flatMapLatest { _ -> Observable<Mutation> in
                        
                        var concat: Observable<Mutation> {
                            /// 화면 전환할 카드 식별자 여부 확인
                            if let targetCardId = pushOrRequestReadInfo.targetCardId {
                                return .concat([
                                    .just(.updatePushOrRequestReadInfo(nil)),
                                    .just(.updatePushOrRequestReadInfo((pushOrRequestReadInfo.detailType, targetCardId)))
                                ])
                            } else {
                                return .just(.updatePushOrRequestReadInfo(nil))
                            }
                        }
                        
                        return concat
                    }
            } else {
                
                var concat: Observable<Mutation> {
                    if let targetCardId = pushOrRequestReadInfo.targetCardId {
                        return .concat([
                            .just(.updatePushOrRequestReadInfo(nil)),
                            .just(.updatePushOrRequestReadInfo((pushOrRequestReadInfo.detailType, targetCardId)))
                        ])
                    } else {
                        return .just(.updatePushOrRequestReadInfo(nil))
                    }
                }
                
                return concat
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .notifications(unreads, reads):
            newState.notificationsForUnread = unreads
            newState.notifications = reads
        case let .more(unreads, reads):
            newState.notificationsForUnread? += unreads
            newState.notifications? += reads
        case let .notices(notices):
            newState.notices = notices
        case let .moreNotices(notices):
            newState.notices? += notices
        case let .updateDisplayType(displayType):
            newState.displayType = displayType
        case let .updatePushOrRequestReadInfo(pushInfo):
            newState.pushInfo = pushInfo
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        case let .updateIsReadSuccess(isReadSuccess):
            newState.isReadSuccess = isReadSuccess
        }
        return newState
    }
}

private extension NotificationViewReactor {
    
    func moreNotification(
        _ activityType: DisplayType.ActivityType,
        with lastId: String
    ) -> Observable<Mutation> {
        
        switch activityType {
        case .unread:
            return self.notificationUseCase.unreadNotifications(lastId: lastId)
                .map { .more(unreads: $0, reads: []) }
        case .read:
            return self.notificationUseCase.readNotifications(lastId: lastId)
                .map { .more(unreads: [], reads: $0) }
        }
    }
}

extension NotificationViewReactor {
    
    struct DisplayStates {
        let displayType: DisplayType
        let unreads: [CompositeNotificationInfo]?
        let reads: [CompositeNotificationInfo]?
        let notices: [NoticeInfo]?
    }
    
    enum DisplayType: Equatable {
        enum ActivityType: Equatable {
            case unread
            case read
        }
        
        case activity(ActivityType)
        case notice
    }
    
    struct PushOrRequestReadInfo: Equatable {
        let detailType: DetailViewReactor.DetailType
        let notificationId: String
        let targetCardId: String?
        let shouldRead: Bool
    }
}

extension NotificationViewReactor {
    
    var catchClosureNotis: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.notifications(unreads: [], reads: [])),
                .just(.updateIsRefreshing(false))
            ])
        }
    }
    
    var catchClosureNotisMore: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.more(unreads: [], reads: [])),
                .just(.updateIsRefreshing(false))
            ])
        }
    }
    
    var catchClosureNotices: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.notices([])),
                .just(.updateIsRefreshing(false))
            ])
        }
    }
    
    var catchClosureNoticesMore: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.moreNotices([])),
                .just(.updateIsRefreshing(false))
            ])
        }
    }
    
    func canUpdatePushInfos(
        prev prevPushInfo: (detailType: DetailViewReactor.DetailType, id: String),
        curr currPushInfo: (detailType: DetailViewReactor.DetailType, id: String)
    ) -> Bool {
        return prevPushInfo.detailType == currPushInfo.detailType &&
            prevPushInfo.id == currPushInfo.id
    }
    
    func canUpdateCells(
        prev prevStates: DisplayStates,
        curr currStates: DisplayStates
    ) -> Bool {
        return prevStates.displayType == currStates.displayType &&
            prevStates.unreads == currStates.unreads &&
            prevStates.reads == currStates.reads &&
            prevStates.notices == currStates.notices
    }
}

extension NotificationViewReactor {
    
    func reactorForDetail(detailType: DetailViewReactor.DetailType, with id: String) -> DetailViewReactor {
        DetailViewReactor(dependencies: self.dependencies, detailType, type: .navi, with: id)
    }
}
