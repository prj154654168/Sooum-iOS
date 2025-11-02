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
        case myWithNavi
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
        case moreWrittenCards([WrittenCard])
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
    
    let provider: ManagerProviderType
    
    let entranceType: EntranceType
    private let memberId: String?
    
    init(provider: ManagerProviderType, type entranceType: EntranceType, memberId: String?) {
        self.provider = provider
        self.entranceType = entranceType
        self.memberId = memberId
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            let combined = Observable.concat([
                self.profile(),
                self.writtenCards()
            ])
                .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                combined,
                .just(.updateIsProcessing(false))
            ])
            
        case .refresh:
            
            let combined = Observable.concat([
                self.profile(),
                self.writtenCards()
            ])
                .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            
            return .concat([
                .just(.updateIsLoading(true)),
                combined,
                .just(.updateIsLoading(false))
            ])
            
        case let .moreFind(lastId):
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.moreWrittenCards(lastId: lastId)
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.updateIsProcessing(false))
            ])
            
        case .block:
            
            if self.currentState.isBlocked {
                let request: ReportRequest = .cancelBlockMember(id: self.memberId ?? "")
                return self.provider.networkManager.request(Empty.self, request: request)
                    .flatMapLatest { _ -> Observable<Mutation> in
                        return .just(.updateIsBlocked(false))
                    }
            } else {
                let request: ReportRequest = .blockMember(id: self.memberId ?? "")
                return self.provider.networkManager.request(Status.self, request: request)
                    .map { .updateIsBlocked($0.httpCode == 201) }
            }
            
        case .follow:
            
            if self.currentState.isFollow == true {
                let request: ProfileRequest = .cancelFollow(memberId: self.memberId ?? "")
                
                return self.provider.networkManager.request(Empty.self, request: request)
                    .flatMapLatest { _ -> Observable<Mutation> in
                        return .just(.updateIsFollow(false))
                    }
            } else {
                let request: ProfileRequest = .requestFollow(memberId: self.memberId ?? "")
                
                return self.provider.networkManager.request(Empty.self, request: request)
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
        case let .moreWrittenCards(writtenCards):
            state.writtenCards += writtenCards
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
            case .my, .myWithNavi:
                return .myProfile
            case .other:
                return .otherProfile(memberId: self.memberId ?? "")
            }
        }
        
        return self.provider.networkManager.request(ProfileResponse.self, request: request)
            .flatMapLatest { response -> Observable<Mutation> in
                if (200...204).contains(response.status.httpCode) {
                    return .just(.profile(response.profile))
                } else {
                    return .just(.profile(.init()))
                }
            }
            .catch(self.catchClosure)
    }
    
    private func writtenCards() -> Observable<Mutation> {
        
        var request: ProfileRequest {
            switch self.entranceType {
            case .my, .myWithNavi:
                return .myCards(lastId: nil)
            case .other:
                return .otherCards(memberId: self.memberId ?? "", lastId: nil)
            }
        }
        
        return self.provider.networkManager.request(WrittenCardResponse.self, request: request)
            .flatMapLatest { response -> Observable<Mutation> in
                if (200...204).contains(response.status.httpCode) {
                    return .just(.writtenCards(response.embedded.writtenCards))
                } else {
                    return .just(.writtenCards(.init()))
                }
            }
            .catch(self.catchClosure)
    }
    
    private func moreWrittenCards(lastId: String) -> Observable<Mutation> {
        
        var request: ProfileRequest {
            switch self.entranceType {
            case .my, .myWithNavi:
                return .myCards(lastId: lastId)
            case .other:
                return .otherCards(memberId: self.memberId ?? "", lastId: lastId)
            }
        }
        
        return self.provider.networkManager.request(WrittenCardResponse.self, request: request)
            .flatMapLatest { response -> Observable<Mutation> in
                if (200...204).contains(response.status.httpCode) {
                    return .just(.moreWrittenCards(response.embedded.writtenCards))
                } else {
                    return .just(.moreWrittenCards(.init()))
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
        SettingsViewReactor(provider: self.provider)
    }
    
    func reactorForUpdate() -> UpdateProfileViewReactor {
        UpdateProfileViewReactor(provider: self.provider, self.currentState.profile)
    }
    
    // func ractorForDetail(_ selectedId: String) -> DetailViewReactor {
    //     DetailViewReactor(provider: self.provider, selectedId)
    // }
    
    func reactorForFollow(type entranceType: FollowViewReactor.EntranceType) -> FollowViewReactor {
        FollowViewReactor(
            provider: self.provider,
            type: entranceType,
            view: self.entranceType == .my ? .my : .other,
            memberId: self.memberId
        )
    }
}
