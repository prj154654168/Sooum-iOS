//
//  OnboardingTermsOfServiceViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 11/14/24.
//

import ReactorKit
import RxCocoa
import RxSwift

class OnboardingTermsOfServiceViewReactor: Reactor {
    
    enum Action {
        case signUp
    }
    
    enum Mutation {
        case signUpResult(Bool)
    }
    
    struct State {
        var shoulNavigate: Bool = false
    }
    
    var initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(type(of: self)) - \(#function)", action)

        switch action {
        case .signUp:
            return join()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .signUpResult(let result):
            newState.shoulNavigate = result
        }
        return newState
    }
    
    private func join() -> Observable<Mutation> {
        return AuthManager.shared.join()
            .map { result in
                Mutation.signUpResult(result)
            }
    }
}
