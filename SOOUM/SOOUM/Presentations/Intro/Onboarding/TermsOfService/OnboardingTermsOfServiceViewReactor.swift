//
//  OnboardingTermsOfServiceViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 11/14/24.
//

import UIKit

import ReactorKit
import RxSwift

class OnboardingTermsOfServiceViewReactor: Reactor {
        
    enum Action {
        /// 모두 동의 버튼 클릭
        case allAgree
        /// 이용약관 버튼 클릭
        case termsOfServiceAgree
        /// 위치 정보 동의 버튼 클릭
        case locationAgree
        /// 개인정보 동의 버튼 클릭
        case privacyPolicyAgree
    }
    
    enum Mutation {
        /// 이용약관 설정
        case updateIsTermsOfServiceAgreed(Bool)
        /// 위치 동의 설정
        case updateIsLocationAgreed(Bool)
        /// 개인정보 동의 설정
        case updateIsPrivacyPolicyAgreed(Bool)
    }
    
    struct State {
        /// 이용약관 동의 여부
        fileprivate(set) var isTermsOfServiceAgreed: Bool
        /// 위치 동의 여부
        fileprivate(set) var isLocationAgreed: Bool
        /// 개인정보 처리 동의 여부
        fileprivate(set) var isPrivacyPolicyAgreed: Bool
        
        /// 전체동의 여부
        var isAllAgreed: Bool {
            return self.isTermsOfServiceAgreed
                && self.isLocationAgreed
                && self.isPrivacyPolicyAgreed
        }
    }
    var initialState = State(
        isTermsOfServiceAgreed: false,
        isLocationAgreed: false,
        isPrivacyPolicyAgreed: false
    )
    
    private let dependencies: AppDIContainerable
    private let authUseCase: AuthUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.authUseCase = dependencies.rootContainer.resolve(AuthUseCase.self)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .termsOfServiceAgree:
            
            return .just(.updateIsTermsOfServiceAgreed(!self.currentState.isTermsOfServiceAgreed))
        case .locationAgree:
            
            return .just(.updateIsLocationAgreed(!self.currentState.isLocationAgreed))
        case .privacyPolicyAgree:
            
            return .just(.updateIsPrivacyPolicyAgreed(!self.currentState.isPrivacyPolicyAgreed))
        case .allAgree:
            
            let isAgreed: Bool = !self.currentState.isAllAgreed
            return .concat([
                .just(.updateIsTermsOfServiceAgreed(isAgreed)),
                .just(.updateIsLocationAgreed(isAgreed)),
                .just(.updateIsPrivacyPolicyAgreed(isAgreed))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateIsTermsOfServiceAgreed(isAgreed):
            newState.isTermsOfServiceAgreed = isAgreed
        case let .updateIsLocationAgreed(isAgreed):
            newState.isLocationAgreed = isAgreed
        case let .updateIsPrivacyPolicyAgreed(isAgreed):
            newState.isPrivacyPolicyAgreed = isAgreed
        }
        return newState
    }
}

extension OnboardingTermsOfServiceViewReactor {
    
    func reactorForNickname() -> OnboardingNicknameSettingViewReactor {
        OnboardingNicknameSettingViewReactor(dependencies: self.dependencies)
    }
}
