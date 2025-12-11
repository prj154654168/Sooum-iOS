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
        case rejoinableDate
        case resetState
    }
    
    enum Mutation {
        case updateBanEndAt(Date?)
        case updateVersion(Version?)
        case updateNotificationStatus(Bool)
        case rejoinableDate(RejoinableDateInfo?)
        case resetState
    }
    
    struct State {
        fileprivate(set) var tokens: Token
        fileprivate(set) var banEndAt: Date?
        fileprivate(set) var version: Version?
        fileprivate(set) var notificationStatus: Bool
        fileprivate(set) var shouldHideTransfer: Bool
        fileprivate(set) var rejoinableDate: RejoinableDateInfo?
    }
    
    var initialState: State
    
    private let dependencies: AppDIContainerable
    private let appVersionUseCase: AppVersionUseCase
    private let authUseCase: AuthUseCase
    private let validateUserUseCase: ValidateUserUseCase
    private let updateNotifyUseCase: UpdateNotifyUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.appVersionUseCase = dependencies.rootContainer.resolve(AppVersionUseCase.self)
        self.authUseCase = dependencies.rootContainer.resolve(AuthUseCase.self)
        self.validateUserUseCase = dependencies.rootContainer.resolve(ValidateUserUseCase.self)
        self.updateNotifyUseCase = dependencies.rootContainer.resolve(UpdateNotifyUseCase.self)
        
        self.initialState = .init(
            tokens: self.authUseCase.tokens(),
            banEndAt: nil,
            version: nil,
            notificationStatus: self.updateNotifyUseCase.notificationStatus(),
            shouldHideTransfer: UserDefaults.standard.bool(forKey: "AppFlag")
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                self.appVersionUseCase.version()
                    .map(Mutation.updateVersion),
                self.validateUserUseCase.postingPermission()
                    .map(\.expiredAt)
                    .map(Mutation.updateBanEndAt),
                self.updateNotifyUseCase.updateNotify(isAllowNotify: self.initialState.notificationStatus)
                    .map(Mutation.updateNotificationStatus)
            ])
        case let .updateNotificationStatus(state):
            
            return self.updateNotifyUseCase.updateNotify(isAllowNotify: state)
                .map { _ in state }
                .map(Mutation.updateNotificationStatus)
        case .rejoinableDate:
            
            return self.validateUserUseCase.iswithdrawn()
                .map(Mutation.rejoinableDate)
        case .resetState:
            
            return .just(.resetState)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState: State = state
        switch mutation {
        case let .updateBanEndAt(banEndAt):
            newState.banEndAt = banEndAt
        case let .updateVersion(version):
            newState.version = version
        case let .updateNotificationStatus(notificationStatus):
            newState.notificationStatus = notificationStatus
        case let .rejoinableDate(rejoinableDate):
            newState.rejoinableDate = rejoinableDate
        case .resetState:
            newState.rejoinableDate = nil
        }
        return newState
    }
}

extension SettingsViewReactor {
    
    func reactorForTransferIssue() -> IssueMemberTransferViewReactor {
        IssueMemberTransferViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForTransferEnter() -> EnterMemberTransferViewReactor {
        EnterMemberTransferViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForBlock() -> BlockUsersViewReactor {
        BlockUsersViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForResign() -> ResignViewReactor {
        ResignViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForAnnouncement() -> AnnouncementViewReactor {
        AnnouncementViewReactor(dependencies: self.dependencies)
    }
}
