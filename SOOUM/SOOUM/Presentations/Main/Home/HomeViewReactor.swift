//
//  HomeViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/28/25.
//

import ReactorKit

import Alamofire

class HomeViewReactor: Reactor {
    
    struct DisplayStates {
        let displayType: DisplayType
        let latests: [BaseCardInfo]?
        let populars: [BaseCardInfo]?
        let distances: [BaseCardInfo]?
    }
    
    enum DisplayType: Equatable {
        case latest
        case popular
        case distance
    }
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFind(String)
        case updateDisplayType(DisplayType)
        case updateDistanceFilter(String)
    }
    
    enum Mutation {
        case cards([BaseCardInfo])
        case more([BaseCardInfo])
        case updateHasUnreadNotifications(Bool)
        case notices([NoticeInfo])
        case updateDisplayType(DisplayType)
        case updateDistanceFilter(String)
        case updateIsRefreshing(Bool)
    }
    
    struct State {
        fileprivate(set) var displayType: DisplayType
        fileprivate(set) var noticeInfos: [NoticeInfo]?
        fileprivate(set) var latestCards: [BaseCardInfo]?
        fileprivate(set) var popularCards: [BaseCardInfo]?
        fileprivate(set) var distanceCards: [BaseCardInfo]?
        fileprivate(set) var hasUnreadNotifications: Bool
        fileprivate(set) var distanceFilter: String
        fileprivate(set) var isRefreshing: Bool
    }
    
    var initialState: State
    
    private let dependencies: AppDIContainerable
    private let cardUseCase: CardUseCase
    private let notificationUseCase: NotificationUseCase
    
    let locationManager: LocationManagerDelegate
    
    init(dependencies: AppDIContainerable, displayType: DisplayType = .latest) {
        self.dependencies = dependencies
        self.cardUseCase = dependencies.rootContainer.resolve(CardUseCase.self)
        self.notificationUseCase = dependencies.rootContainer.resolve(NotificationUseCase.self)
        
        self.locationManager = dependencies.rootContainer.resolve(ManagerProviderType.self).locationManager
        
        self.initialState = State(
            displayType: displayType,
            noticeInfos: nil,
            latestCards: nil,
            popularCards: nil,
            distanceCards: nil,
            hasUnreadNotifications: false,
            distanceFilter: "1km",
            isRefreshing: false
        )
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            let displayType = self.currentState.displayType
            let distanceFilter = self.currentState.distanceFilter
            return .concat([
                self.refresh(displayType, distanceFilter)
                    .catch(self.catchClosureForCards),
                self.unreadNotifications()
                    .catch(self.catchClosureForNotis)
            ])
        case .refresh:
            
            let displayType = self.currentState.displayType
            let distanceFilter = self.currentState.distanceFilter
            return .concat([
                .just(.updateIsRefreshing(true)),
                self.refresh(displayType, distanceFilter)
                    .catch(self.catchClosureForCards),
                self.unreadNotifications()
                    .catch(self.catchClosureForNotis),
                .just(.updateIsRefreshing(false))
            ])
        case let .moreFind(lastId):
            
            return self.moreFind(lastId)
                .catch(self.catchClosureForMore)
        case let .updateDisplayType(displayType):
            
            let distanceFilter = self.currentState.distanceFilter
            var emitObservable: Observable<Mutation> {
                switch displayType {
                case .latest:
                    if let latestCards = self.currentState.latestCards {
                        return .just(.cards(latestCards))
                    } else {
                        return self.refresh(.latest, distanceFilter)
                            .catch(self.catchClosureForCards)
                    }
                case .popular:
                    if let popularCards = self.currentState.popularCards {
                        return .just(.cards(popularCards))
                    } else {
                        return self.refresh(.popular, distanceFilter)
                            .catch(self.catchClosureForCards)
                    }
                case .distance:
                    if let distanceCards = self.currentState.distanceCards {
                        return .just(.cards(distanceCards))
                    } else {
                        return self.refresh(.distance, distanceFilter)
                            .catch(self.catchClosureForCards)
                    }
                }
            }
            
            return .concat([
                .just(.updateDisplayType(displayType)),
                emitObservable
            ])
        case let .updateDistanceFilter(distanceFilter):
            
            let displayType = self.currentState.displayType
            return .concat([
                .just(.updateDistanceFilter(distanceFilter)),
                self.refresh(displayType, distanceFilter)
                    .catch(self.catchClosureForCards)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .cards(cards):
            switch newState.displayType {
            case .latest: newState.latestCards = cards
            case .popular: newState.popularCards = cards
            case .distance: newState.distanceCards = cards
            }
        case let .more(cards):
            switch newState.displayType {
            case .latest: newState.latestCards? += cards
            case .distance: newState.distanceCards? += cards
            default: break
            }
        case let .notices(noticeInfos):
            newState.noticeInfos = noticeInfos
        case let .updateHasUnreadNotifications(hasUnreadNotifications):
            newState.hasUnreadNotifications = hasUnreadNotifications
        case let .updateDisplayType(displayType):
            newState.displayType = displayType
        case let .updateDistanceFilter(distanceFilter):
            newState.distanceFilter = distanceFilter
        case let .updateIsRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        }
        return newState
    }
}

private extension HomeViewReactor {
    
    func refresh(_ displayType: DisplayType, _ distanceFilter: String) -> Observable<Mutation> {

        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        switch displayType {
        case .latest:
            return self.cardUseCase.latestCard(lastId: nil, latitude: latitude, longitude: longitude)
                .map(Mutation.cards)
        case .popular:
            return self.cardUseCase.popularCard(latitude: latitude, longitude: longitude)
                .map(Mutation.cards)
        case .distance:
            let distanceFilter = distanceFilter.replacingOccurrences(of: "km", with: "")
            return self.cardUseCase.distanceCard(
                lastId: nil,
                latitude: latitude,
                longitude: longitude,
                distanceFilter: distanceFilter
            )
            .map(Mutation.cards)
        }
    }
    
    func moreFind(_ lastId: String) -> Observable<Mutation> {
        
        let latitude = self.locationManager.coordinate.latitude
        let longitude = self.locationManager.coordinate.longitude
        
        switch self.currentState.displayType {
        case .latest:
            return self.cardUseCase.latestCard(lastId: lastId, latitude: latitude, longitude: longitude)
                .map(Mutation.more)
        case .distance:
            let distanceFilter = self.currentState.distanceFilter.replacingOccurrences(of: "km", with: "")
            return self.cardUseCase.distanceCard(
                lastId: lastId,
                latitude: latitude,
                longitude: longitude,
                distanceFilter: distanceFilter
            )
            .map(Mutation.more)
        default:
            return .empty()
        }
    }
    
    func unreadNotifications() -> Observable<Mutation> {
        
        return self.notificationUseCase.notices(lastId: nil, size: 3, requestType: .notification)
            .flatMapLatest { noticeInfos -> Observable<Mutation> in
                
                return .concat([
                    self.notificationUseCase.unreadNotifications(lastId: nil)
                        .map { .updateHasUnreadNotifications($0.isEmpty == false && noticeInfos.isEmpty == false) },
                    .just(.notices(noticeInfos))
                ])
            }
    }
}

extension HomeViewReactor {
    
    var catchClosureForCards: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.cards([])),
                .just(.updateIsRefreshing(false))
            ])
        }
    }
    
    var catchClosureForMore: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.more([])),
                .just(.updateIsRefreshing(false))
            ])
        }
    }
    
    var catchClosureForNotis: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.notices([])),
                .just(.updateHasUnreadNotifications(false)),
                .just(.updateIsRefreshing(false))
            ])
        }
    }
  
    func canUpdateCells(
        prev prevDisplayState: DisplayStates,
        curr currDisplayState: DisplayStates
    ) -> Bool {
        return prevDisplayState.displayType == currDisplayState.displayType &&
            prevDisplayState.latests == currDisplayState.latests &&
            prevDisplayState.populars == currDisplayState.populars &&
            prevDisplayState.distances == currDisplayState.distances
    }
}


extension HomeViewReactor {
    
    func reactorForNotification(with displayType: NotificationViewReactor.DisplayType = .activity(.unread)) -> NotificationViewReactor {
        NotificationViewReactor(dependencies: self.dependencies, displayType: displayType)
    }
    
    func reactorForDetail(with id: String) -> DetailViewReactor {
        DetailViewReactor(dependencies: self.dependencies, .feed, with: id)
    }
}
