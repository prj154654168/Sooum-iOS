//
//  ProfileViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/24.
//

import ReactorKit

import Alamofire


class ProfileViewReactor: Reactor {
    
    enum EntranceType {
        case my
        case other
    }
    
    enum Action: Equatable {
        case landing
        case refresh
        case moreFind(String)
        case block
        case follow
    }
    
    enum Mutation {
        case profile(Profile)
        case writtenCards([WrittenCard])
        case updateIsBlocked(Bool)
        case updateIsFollow(Bool)
        case updateIsLoading(Bool)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var profile: Profile
        var writtenCards: [WrittenCard]
        var isBlocked: Bool
        var isFollow: Bool?
        var isLoading: Bool
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        profile: .init(),
        writtenCards: [],
        isBlocked: false,
        isFollow: nil,
        isLoading: false,
        isProcessing: false
    )
    
    private let networkManager = NetworkManager.shared
    
    let entranceType: EntranceType
    private let memberId: String?
    
    init(type entranceType: EntranceType, memberId: String?) {
        self.entranceType = entranceType
        self.memberId = memberId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            return .concat([
                .just(.updateIsProcessing(true)),
                self.profile(),
                self.writtenCards(nil)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsProcessing(false))
            ])
        case .refresh:
            return .concat([
                .just(.updateIsLoading(true)),
                self.profile(),
                self.writtenCards(nil)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsLoading(false))
            ])
        case let .moreFind(lastId):
            return .concat([
                .just(.updateIsProcessing(true)),
                self.writtenCards(lastId),
                .just(.updateIsProcessing(false))
            ])
        case .block:
            let request: ReportRequest = .blockMember(id: self.memberId ?? "")
            return self.networkManager.request(Status.self, request: request)
                .map { .updateIsBlocked($0.httpCode == 201) }
        case .follow:
            if self.currentState.isFollow == true { 
                let request: ProfileRequest = .cancelFollow(memberId: self.memberId ?? "")
                
                return self.networkManager.request(Empty.self, request: request)
                    .flatMapLatest { _ -> Observable<Mutation> in
                        return .just(.updateIsFollow(false))
                    }
            } else {
                let request: ProfileRequest = .requestFollow(memberId: self.memberId ?? "")
                
                return self.networkManager.request(Empty.self, request: request)
                    .flatMapLatest { _ -> Observable<Mutation> in
                        return .just(.updateIsFollow(true))
                    }
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
        case let .profile(profile):
            state.profile = profile
        case let .writtenCards(writtenCards):
            state.writtenCards = writtenCards
        case let .updateIsBlocked(isBlocked):
            state.isBlocked = isBlocked
        case let .updateIsFollow(isFollow):
            state.isFollow = isFollow
        case let .updateIsLoading(isLoading):
            state.isLoading = isLoading
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        }
        return state
    }
}

extension ProfileViewReactor {
    
    private func profile() -> Observable<Mutation> {
        
        var request: ProfileRequest {
            switch self.entranceType {
            case .my:
                return .myProfile
            case .other:
                return .otherProfile(memberId: self.memberId ?? "")
            }
        }
        
        return self.networkManager.request(ProfileResponse.self, request: request)
            .flatMapLatest { response -> Observable<Mutation> in
                if (200...204).contains(response.status.httpCode) {
                    return .just(.profile(response.profile))
                } else {
                    return .just(.profile(.init()))
                }
            }
            .catch(self.catchClosure)
    }
    
    private func writtenCards(_ lastId: String?) -> Observable<Mutation> {
        
        var request: ProfileRequest {
            switch self.entranceType {
            case .my:
                return .myCards(lastId: lastId)
            case .other:
                return .otherCards(memberId: self.memberId ?? "", lastId: lastId)
            }
        }
        
        return self.networkManager.request(WrittenCardResponse.self, request: request)
            .flatMapLatest { response -> Observable<Mutation> in
                if (200...204).contains(response.status.httpCode) {
                    return .just(.writtenCards(response.embedded.writtenCards))
                } else {
                    return .just(.writtenCards(.init()))
                }
            }
            .catch(self.catchClosure)
    }
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.updateIsProcessing(false)),
                .just(.updateIsLoading(false))
            ])
        }
    }
}

extension ProfileViewReactor {
    
    func reactorForSettings() -> SettingsViewReactor {
        SettingsViewReactor.init()
    }
    
    func reactorForUpdate() -> UpdateProfileViewReactor {
        UpdateProfileViewReactor.init(self.currentState.profile)
    }
    
    func ractorForDetail(_ selectedId: String) -> DetailViewReactor {
        DetailViewReactor(type: .mainHome, selectedId)
    }
    
    func reactorForFollow(type entranceType: FollowViewReactor.EntranceType) -> FollowViewReactor {
        let viewType: FollowViewReactor.ViewType = self.entranceType == .my ? .my : .other
        return FollowViewReactor(type: entranceType, view: viewType, memberId: self.memberId)
    }
}
