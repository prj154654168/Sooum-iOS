//
//  EnterMemberTransferViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit

import Alamofire


class EnterMemberTransferViewReactor: Reactor {
    
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
    }
    
    var initialState: State = .init(
        isSuccess: false,
        isProcessing: false
    )
    
    private let networkManager = NetworkManager.shared
    private let authManager = AuthManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .enterTransferCode(transferCode):
            
            return .concat([
                .just(.updateIsProcessing(true)),
                
                self.networkManager.request(RSAKeyResponse.self, request: AuthRequest.getPublicKey)
                    .map(\.publicKey)
                    .withUnretained(self)
                    .flatMapLatest { object, publicKey -> Observable<Mutation> in
                        
                        if let secKey = object.authManager.convertPEMToSecKey(pemString: publicKey),
                           let encryptedDeviceId = object.authManager.encryptUUIDWithPublicKey(publicKey: secKey) {
                            
                            let request: SettingsRequest = .transferMember(
                                transferId: transferCode,
                                encryptedDeviceId: encryptedDeviceId
                            )
                            
                            return self.networkManager.request(Empty.self, request: request)
                                .flatMapLatest { _ -> Observable<Mutation> in
                                    return .just(.enterTransferCode(true))
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
                .just(.updateIsProcessing(false))
            ])
        }
    }
}
