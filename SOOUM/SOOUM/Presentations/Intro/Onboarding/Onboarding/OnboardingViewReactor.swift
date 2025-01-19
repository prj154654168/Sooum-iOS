//
//  OnboardingViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 1/15/25.
//

import ReactorKit


class OnboardingViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case reset
        case check
    }
    
    
    enum Mutation {
        case check(Suspension)
        case shouldNavigate(Bool)
    }

    struct State {
        fileprivate(set) var suspension: Suspension?
        fileprivate(set) var shouldNavigate: Bool = false
    }

    var initialState: State = .init(
        suspension: nil
    )
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.check()
                .compactMap(\.value)
                .map(Mutation.check)
        case .reset:
            
            return .just(.shouldNavigate(false))
        case .check:
            
            return self.check()
                .map { $0 == nil }
                .map(Mutation.shouldNavigate)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .check(suspension):
            state.suspension = suspension
        case let .shouldNavigate(shouldNavigate):
            state.shouldNavigate = shouldNavigate
        }
        return state
    }
}

extension OnboardingViewReactor {
    
    private func check() -> Observable<Suspension?> {
        
        return self.provider.networkManager.request(
            RSAKeyResponse.self,
            request: AuthRequest.getPublicKey
        )
        .map(\.publicKey)
        .withUnretained(self)
        .flatMapLatest { object, publicKey -> Observable<Suspension?> in
            
            if let secKey = object.provider.authManager.convertPEMToSecKey(pemString: publicKey),
               let encryptedDeviceId = object.provider.authManager.encryptUUIDWithPublicKey(publicKey: secKey) {
                
                let request: JoinRequest = .suspension(encryptedDeviceId: encryptedDeviceId)
                return object.provider.networkManager.request(SuspensionResponse.self, request: request)
                    .map(\.suspension)
            } else {
                return .empty()
            }
        }
    }
}

extension OnboardingViewReactor {
    
    func reactorForTermsOfService() -> OnboardingTermsOfServiceViewReactor {
        OnboardingTermsOfServiceViewReactor(provider: self.provider)
    }
    
    func reactorForEnterTransfer() -> EnterMemberTransferViewReactor {
        EnterMemberTransferViewReactor(provider: self.provider, entranceType: .onboarding)
    }
}
