//
//  IssueMemberTransferViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import ReactorKit


class IssueMemberTransferViewReactor: Reactor {
    
    enum Action: Equatable {
        case landing
        case updateTransferCode
    }
    
    enum Mutation {
        case updateTransferCode(String)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var trnsferCode: String
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        trnsferCode: "",
        isProcessing: false
    )
    
    private let networkManager = NetworkManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            let request: SettingsRequest = .transferCode(isUpdate: false)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.networkManager.request(TransferCodeResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.updateTransferCode(response.transferCode))
                    },
                .just(.updateIsProcessing(false))
            ])
        case .updateTransferCode:
            let request: SettingsRequest = .transferCode(isUpdate: true)
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.networkManager.request(TransferCodeResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        return .just(.updateTransferCode(response.transferCode))
                    },
                .just(.updateIsProcessing(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .updateTransferCode(transferCode):
            state.trnsferCode = transferCode
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        }
        return state
    }
}
