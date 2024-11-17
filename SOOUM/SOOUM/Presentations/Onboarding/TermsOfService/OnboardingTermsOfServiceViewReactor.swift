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
        case allAgree
        case termsOfServiceAgree
        case locationAgree
        case privacyPolicyAgree
    }
    
    enum Mutation {
        case signUpResult(Bool)
        case setIsAllAgreed(Bool)
        case setIsTermsOfServiceAgreed(Bool)
        case setIsLocationAgreed(Bool)
        case setIsPrivacyPolicyAgreed(Bool)
        case setIsAgreedStats([TermsOfService: Bool])
    }
    
    struct State {
        fileprivate(set) var shoulNavigate: Bool = false
        fileprivate(set) var isAllAgreed: Bool = false
        fileprivate(set) var isTermsOfServiceAgreed = false
        fileprivate(set) var isLocationAgreed = false
        fileprivate(set) var isPrivacyPolicyAgreed = false
        fileprivate(set) var isAgreedStats: [TermsOfService: Bool] = [
            TermsOfService.termsOfService: false,
            TermsOfService.locationService: false,
            TermsOfService.privacyPolicy: false
        ]
    }
        
    var initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        print("\(type(of: self)) - \(#function)", action)

        switch action {
        case .signUp:
            return join()
            
        case .termsOfServiceAgree:
            return .concat([
                .just(.setIsTermsOfServiceAgreed(!self.currentState.isTermsOfServiceAgreed)),
                self.checkIsAllAgreed(type: .termsOfService)
            ])
            
        case .locationAgree:
            return .concat([
                .just(.setIsLocationAgreed(!self.currentState.isLocationAgreed)),
                self.checkIsAllAgreed(type: .locationService)
            ])
            
        case .privacyPolicyAgree:
            return .concat([
                .just(.setIsPrivacyPolicyAgreed(!self.currentState.isPrivacyPolicyAgreed)),
                self.checkIsAllAgreed(type: .privacyPolicy)
            ])
            
        case .allAgree:
            let isAgreed: Bool = !self.currentState.isAllAgreed
            return .concat([
                .just(.setIsTermsOfServiceAgreed(isAgreed)),
                .just(.setIsLocationAgreed(isAgreed)),
                .just(.setIsPrivacyPolicyAgreed(isAgreed)),
                .just(.setIsAllAgreed(isAgreed))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .signUpResult(result):
            newState.shoulNavigate = result
            
        case let .setIsTermsOfServiceAgreed(isAgreed):
            newState.isTermsOfServiceAgreed = isAgreed
            
        case let .setIsLocationAgreed(isAgreed):
            newState.isLocationAgreed = isAgreed
            
        case let .setIsPrivacyPolicyAgreed(isAgreed):
            newState.isPrivacyPolicyAgreed = isAgreed
            
        case let .setIsAllAgreed(isAgreed):
            newState.isAllAgreed = isAgreed
            
        case let .setIsAgreedStats(statsDict):
            newState.isAgreedStats = statsDict
        }
        return newState
    }
    
    private func join() -> Observable<Mutation> {
        return AuthManager.shared.join()
            .map { result in
                Mutation.signUpResult(result)
            }
    }
    
    private func checkIsAllAgreed(type: TermsOfService) -> Observable<Mutation> {
        var isTermsOfServiceAgreed = self.currentState.isTermsOfServiceAgreed
        var isLocationAgreed = self.currentState.isLocationAgreed
        var isPrivacyPolicyAgreed = self.currentState.isPrivacyPolicyAgreed
        
        switch type {
        case .termsOfService:
            isTermsOfServiceAgreed.toggle()
            
        case .locationService:
            isLocationAgreed.toggle()
            
        case .privacyPolicy:
            isPrivacyPolicyAgreed.toggle()
        }
        
        let newStats: [TermsOfService: Bool] = [
            TermsOfService.termsOfService: isTermsOfServiceAgreed,
            TermsOfService.locationService: isLocationAgreed,
            TermsOfService.privacyPolicy: isPrivacyPolicyAgreed
        ]

        return .just(.setIsAgreedStats(newStats))
    }
}

enum TermsOfService: CaseIterable {
    case termsOfService
    case locationService
    case privacyPolicy
    
    var text: String {
        switch self {
        case .termsOfService:
            "[필수] 서비스 이용 약관"
        case .locationService:
            "[필수] 위치정보 이용 약관"
        case .privacyPolicy:
            "[필수] 개인정보 처리 방침"
        }
    }
}
