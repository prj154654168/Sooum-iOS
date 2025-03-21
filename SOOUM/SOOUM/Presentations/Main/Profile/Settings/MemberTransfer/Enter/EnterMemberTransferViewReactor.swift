//
//  EnterMemberTransferViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit

import Alamofire


class EnterMemberTransferViewReactor: Reactor {
    
    enum EntranceType {
        case onboarding
        case settings
    }
    
    enum Action: Equatable {
        case enterTransferCode(String)
    }
    
    enum Mutation {
        case enterTransferCode(Bool)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var isSuccess: Bool
        var isProcessing: Bool
        let entranceType: EntranceType
    }
    
    var initialState: State
    
    let provider: ManagerProviderType
  
    init(provider: ManagerProviderType, entranceType: EntranceType) {
        self.provider = provider
        self.initialState = .init(
            isSuccess: false,
            isProcessing: false,
            entranceType: entranceType
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .enterTransferCode(transferCode):
            
            return .concat([
                .just(.updateIsProcessing(true)),
                
                self.provider.networkManager.request(RSAKeyResponse.self, request: AuthRequest.getPublicKey)
                    .map(\.publicKey)
                    .withUnretained(self)
                    .flatMapLatest { object, publicKey -> Observable<Mutation> in
                        
                        if let secKey = object.provider.authManager.convertPEMToSecKey(pemString: publicKey),
                           let encryptedDeviceId = object.provider.authManager.encryptUUIDWithPublicKey(publicKey: secKey) {
                            
                            let request: SettingsRequest = .transferMember(
                                transferId: transferCode,
                                encryptedDeviceId: encryptedDeviceId
                            )
                            
                            return self.provider.networkManager.request(Status.self, request: request)
                                .withUnretained(self)
                                .flatMapLatest { object, response -> Observable<Mutation> in
                                    object.provider.authManager.initializeAuthInfo()
                                    
                                    return .just(.enterTransferCode(response.httpCode != 400))
                                }
                        } else {
                            return .just(.enterTransferCode(false))
                        }
                    }
                    .catch(self.catchClosure),
                
                .just(.updateIsProcessing(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .enterTransferCode(isSuccess):
            state.isSuccess = isSuccess
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        }
        return state
    }
}

extension EnterMemberTransferViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.enterTransferCode(false)),
                .just(.updateIsProcessing(false))
            ])
        }
    }
}

extension EnterMemberTransferViewReactor {
    
    func reactorForLaunch() -> LaunchScreenViewReactor {
        LaunchScreenViewReactor(provider: self.provider)
    }
}
