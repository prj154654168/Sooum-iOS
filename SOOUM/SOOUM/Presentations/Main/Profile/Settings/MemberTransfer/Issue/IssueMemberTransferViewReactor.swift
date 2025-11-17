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
        case updateTransferInfo(TransferCodeInfo)
        case updateIsProcessing(Bool)
    }
    
    struct State {
        var trnsferCodeInfo: TransferCodeInfo?
        var isProcessing: Bool
    }
    
    var initialState: State = .init(
        trnsferCodeInfo: nil,
        isProcessing: false
    )
    
    private let dependencies: AppDIContainerable
    private let settingsUseCase: SettingsUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.settingsUseCase = dependencies.rootContainer.resolve(SettingsUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.settingsUseCase.issue()
                .map(Mutation.updateTransferInfo)
        case .updateTransferCode:
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.settingsUseCase.update()
                    .map(Mutation.updateTransferInfo)
                    .catch(self.catchClosure)
                    .delay(.milliseconds(1000), scheduler: MainScheduler.instance),
                .just(.updateIsProcessing(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .updateTransferInfo(trnsferCodeInfo):
            state.trnsferCodeInfo = trnsferCodeInfo
        case let .updateIsProcessing(isProcessing):
            state.isProcessing = isProcessing
        }
        return state
    }
}

extension IssueMemberTransferViewReactor {
    
    var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { _ in
            .concat([
                .just(.updateIsProcessing(false))
            ])
        }
    }
}
