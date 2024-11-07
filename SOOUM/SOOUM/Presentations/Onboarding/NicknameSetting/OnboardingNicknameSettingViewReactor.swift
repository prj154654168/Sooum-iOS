//
//  OnboardingNicknameSettingViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 11/7/24.
//

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

class OnboardingNicknameSettingViewReactor: Reactor {
    
    enum Action: Equatable {
        case textChanged(String)
    }
    
    enum Mutation {
        case setNicknameResult(Result<(nickname: String, isValid: Bool), Error>)
    }
    
    struct State {
        var nickname: String = ""
        var isNicknameValid: Bool? = nil
        var errorMessage: String? = nil
    }
    
    var initialState = State()
    
    
    private func validateNickname(_ nickname: String) -> Observable<Result<(String, Bool), Error>> {

    }
}
