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
    }
    
    
    enum Mutation {
        case check(Suspension?)
    }

    struct State {
        fileprivate(set) var suspension: Suspension?
        fileprivate(set) var shouldHideTransfer: Bool
    }

    var initialState: State = .init(
        suspension: nil,
        shouldHideTransfer: UserDefaults.standard.bool(forKey: "AppFlag")
    )
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return .concat([
                self.check()
                    .compactMap(Mutation.check),
                self.provider.pushManager.switchNotification(on: true)
                    .flatMapLatest { _ -> Observable<Mutation> in .empty() }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .check(suspension):
            newState.suspension = suspension
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
                return .just(nil)
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
