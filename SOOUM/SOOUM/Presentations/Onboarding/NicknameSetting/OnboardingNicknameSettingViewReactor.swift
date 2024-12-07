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
    
    enum NicknameState {
        case vaild
        case emptyName
        case invalid
        
        var desc: String {
            switch self {
            case .vaild:
                ""
            case .emptyName:
                "한 글자 이상 입력해주세요."
            case .invalid:
                "부적절한 닉네임입니다."
            }
        }
    }

    enum Action {
        case checkNicknameValidation(String)
    }

    enum Mutation {
        case setNicknameResult(Result<(nickname: String, isValid: NicknameState), Error>)
    }

    struct State {
        var nickname: String = ""
        var isNicknameValid: NicknameState?
        var errorMessage: String?
    }

    var initialState = State()
    private let networkManager = NetworkManager.shared

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkNicknameValidation(let nickname):
            return validateNickname(nickname)
                .map { result in
                    Mutation.setNicknameResult(result)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNicknameResult(let result):
            switch result {
            case .success(let (nickname, isValid)):
                newState.nickname = nickname
                newState.isNicknameValid = isValid
                newState.errorMessage = isValid.desc
            case .failure(let error):
                newState.isNicknameValid = .invalid
                newState.errorMessage = error.localizedDescription
            }
        }
        return newState
    }
    
    private func validateNickname(_ nickname: String) -> Observable<Result<(nickname: String, isValid: NicknameState), Error>> {
        let request: JoinRequest = .validateNickname(nickname: nickname)
        
        if nickname.isEmpty {
            // 닉네임이 비어있다면 유효하지 않음을 즉시 반환
            return Observable.just(.success((nickname: nickname, isValid: .emptyName)))
        }
        
        return networkManager.request(NicknameValidationResponse.self, request: request)
            .map { response in
                Result.success((nickname: nickname, isValid: response.isAvailable ? .vaild : .invalid))
            }
            .catch { error in
                Observable.just(Result.failure(error))
            }
    }
}
