//
//  OnboardingNicknameSettingViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 11/7/24.
//

import ReactorKit
import RxCocoa
import RxSwift

class OnboardingNicknameSettingViewReactor: Reactor {
    
    enum ErrorMessages: String {
        case isEmpty = "한글자 이상 입력해주세요"
        case inValid = "부적절한 닉네임입니다. 다시 입력해주세요"
    }

    enum Action {
        case checkValidate(String)
    }

    enum Mutation {
        case updateIsValid(Bool)
        case updateIsErrorMessage(String?)
    }

    struct State {
        var isValid: Bool
        var errorMessage: String?
    }

    var initialState: State = .init(
        isValid: false,
        errorMessage: nil
    )
    
    let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .checkValidate(nickname):
            if nickname.isEmpty {
                return .concat([
                    .just(.updateIsValid(false)),
                    .just(.updateIsErrorMessage(ErrorMessages.isEmpty.rawValue))
                ])
            }
            let request: JoinRequest = .validateNickname(nickname: nickname)
            
            return .concat([
                .just(.updateIsErrorMessage(nil)),
                self.provider.networkManager.request(NicknameValidationResponse.self, request: request)
                    .flatMapLatest { response -> Observable<Mutation> in
                        let isAvailable = response.isAvailable
                        let errorMessage = isAvailable ? nil : ErrorMessages.inValid.rawValue
                        return .concat([
                            .just(.updateIsValid(isAvailable)),
                            .just(.updateIsErrorMessage(errorMessage))
                        ])
                    }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateIsValid(isValid):
            newState.isValid = isValid
        case let .updateIsErrorMessage(errorMessage):
            newState.errorMessage = errorMessage
        }
        return newState
    }
}

extension OnboardingNicknameSettingViewReactor {
    
    func reactorForProfileImage(nickname: String) -> OnboardingProfileImageSettingViewReactor {
        OnboardingProfileImageSettingViewReactor(provider: self.provider, nickname: nickname)
    }
}
