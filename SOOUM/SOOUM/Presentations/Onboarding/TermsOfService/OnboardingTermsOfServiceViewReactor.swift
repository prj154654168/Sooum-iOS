//
//  OnboardingTermsOfServiceViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 11/14/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

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
    var indexPath: IndexPath {
        switch self {
        case .termsOfService: IndexPath(row: 0, section: 0)
        case .locationService: IndexPath(row: 1, section: 0)
        case .privacyPolicy: IndexPath(row: 2, section: 0)
        }
    }
}

class OnboardingTermsOfServiceViewReactor: Reactor {
        
    enum Action {
        /// 약관동의 전 회원가입
        case signUp
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
        /// 약관동의 전 가입 api 결과
        case signUpResult(Bool)
        /// 이용약관 설정
        case setIsTermsOfServiceAgreed(Bool)
        /// 위치 동의 설정
        case setIsLocationAgreed(Bool)
        /// 개인정보 동의 설정
        case setIsPrivacyPolicyAgreed(Bool)
    }
    
    struct State {
        /// 다음 화면으로 넘어가기 필요 여부
        fileprivate(set) var shoulNavigate: Bool = false
        /// 이용약관 동의 여부
        fileprivate(set) var isTermsOfServiceAgreed = false
        /// 위치 동의 여부
        fileprivate(set) var isLocationAgreed = false
        /// 개인정보 처리 동의 여부
        fileprivate(set) var isPrivacyPolicyAgreed = false
        
        /// 전체동의 여부
        var isAllAgreed: Bool {
            return self.isTermsOfServiceAgreed
                && self.isLocationAgreed
                && self.isPrivacyPolicyAgreed
        }
    }
        
    var initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .signUp:
            return join()
            
        case .termsOfServiceAgree:
            return .just(.setIsTermsOfServiceAgreed(!self.currentState.isTermsOfServiceAgreed))
            
        case .locationAgree:
            return .just(.setIsLocationAgreed(!self.currentState.isLocationAgreed))
            
        case .privacyPolicyAgree:
            return .just(.setIsPrivacyPolicyAgreed(!self.currentState.isPrivacyPolicyAgreed))
            
        case .allAgree:
            let isAgreed: Bool = !self.currentState.isAllAgreed
            return .concat([
                .just(.setIsTermsOfServiceAgreed(isAgreed)),
                .just(.setIsLocationAgreed(isAgreed)),
                .just(.setIsPrivacyPolicyAgreed(isAgreed))
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
