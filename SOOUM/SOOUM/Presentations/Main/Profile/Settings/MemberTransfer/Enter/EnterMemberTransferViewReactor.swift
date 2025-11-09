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
        case enterTransferCode(Bool?)
    }
    
    struct State {
        var isSuccess: Bool?
    }
    
    var initialState: State = State(isSuccess: nil)
    
    private let dependencies: AppDIContainerable
    private let settingsUseCase: SettingsUserCase
    
    private let authManager: AuthManagerDelegate
  
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.settingsUseCase = dependencies.rootContainer.resolve(SettingsUserCase.self)
        self.authManager = dependencies.rootContainer.resolve(ManagerProviderType.self).authManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .enterTransferCode(transferCode):
            
            return .concat([
                .just(.enterTransferCode(nil)),
                self.authManager.publicKey()
                    .withUnretained(self)
                    .flatMapLatest { object, publicKey -> Observable<Mutation> in
                        
                        if let publicKey = publicKey,
                           let secKey = object.authManager.convertPEMToSecKey(pemString: publicKey),
                           let encryptedDeviceId = object.authManager.encryptUUIDWithPublicKey(publicKey: secKey) {
                            
                            return object.settingsUseCase.enter(code: transferCode, encryptedDeviceId: encryptedDeviceId)
                                .map(Mutation.enterTransferCode)
                        } else {
                            return .just(.enterTransferCode(false))
                        }
                    }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .enterTransferCode(isSuccess):
            state.isSuccess = isSuccess
        }
        return state
    }
}

extension EnterMemberTransferViewReactor {
    
    func reactorForLaunch() -> LaunchScreenViewReactor {
        LaunchScreenViewReactor(dependencies: self.dependencies, pushInfo: nil)
    }
}
