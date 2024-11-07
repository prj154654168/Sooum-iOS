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

    enum Action {
        case textChanged(String)
    }

    enum Mutation {
        case setNicknameResult(Result<(nickname: String, isValid: Bool), Error>)
    }

    struct State {
        var nickname: String = ""
        var isNicknameValid: Bool?
        var errorMessage: String?
    }

    var initialState = State()
    private let networkManager = NetworkManager.shared

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(type(of: self)) - \(#function)", action)

        switch action {
        case .textChanged(let nickname):
            return validateNickname(nickname)
                .map { result in
                    Mutation.setNicknameResult(result)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        print("\(type(of: self)) - \(#function)", mutation)
        switch mutation {
        case .setNicknameResult(let result):
            switch result {
            case .success(let (nickname, isValid)):
                newState.nickname = nickname
                newState.isNicknameValid = isValid
                newState.errorMessage = nil
            case .failure(let error):
                newState.isNicknameValid = false
                newState.errorMessage = error.localizedDescription
            }
        }
        return newState
    }
    
    private func validateNickname(_ nickname: String) -> Observable<Result<(nickname: String, isValid: Bool), Error>> {
        let request: JoinRequest = .validateNickname(nickname: nickname)
        print("\(type(of: self)) - \(#function)", nickname)

        return networkManager.request(NicknameValidationResponse.self, request: request)
            .map { response in
                Result.success((nickname: nickname, isValid: response.isAvailable))
            }
            .catch { error in
                Observable.just(Result.failure(error))
            }
    }
}
