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
            guard let encryptedDeviceId = String(
                data: self.authManager.authInfo.deviceId,
                encoding: .utf8
            ) else {
                return .empty()
            }
            let request: SettingsRequest = .transferMember(
                transferId: transferCode,
                encryptedDeviceId: encryptedDeviceId
            )
            
            return self.networkManager.request(Empty.self, request: request)
                .flatMapLatest { _ -> Observable<Mutation> in
                    return .just(.enterTransferCode(true))
                }
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
