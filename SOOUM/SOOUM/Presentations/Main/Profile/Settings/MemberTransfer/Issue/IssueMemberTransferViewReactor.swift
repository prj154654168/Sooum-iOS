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
    private let transferAccountUseCase: TransferAccountUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.transferAccountUseCase = dependencies.rootContainer.resolve(TransferAccountUseCase.self)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.transferAccountUseCase.issue()
                .map(Mutation.updateTransferInfo)
        case .updateTransferCode:
            
            return .concat([
                .just(.updateIsProcessing(true)),
                self.transferAccountUseCase.update()
                    .map(Mutation.updateTransferInfo)
                    .catchAndReturn(.updateIsProcessing(false))
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
