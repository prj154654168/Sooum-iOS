//
//  LaunchScreenViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import ReactorKit


/*
 - 어플 실행
 - RSA 공개 키 요청
 - 로그인 API 호출 (IMEI RSA 암호화)
     - DB에 저장된 DeviceId가 존재하는가? → Y
         - 토큰 발급 로직
     - DB에 저장된 DeviceId가 존재하는가? → N
         - 약관 동의
         - DB 유저 정보 저장 (회원가입 API 호출)
         - 토큰 발급 로직
 */
class LaunchScreenViewReactor: Reactor {
    
    // MARK: - Action
    enum Action: Equatable {
        /// 앱이 시작되었을 때, 로그인 및 회원가입 처리 흐름을 시작
        case launch
    }
    
    // MARK: - Mutation
    enum Mutation {
        /// 로딩 상태 설정
        case setLoading(Bool)
        /// 기존 회원 로그인 성공
        case setLoginSuccess
        /// 회원가입 후 로그인 성공
        case setSignupSuccess
        /// 에러가 발생했을 때 에러 메시지를 설정
        case setError(String)
    }
    
    // MARK: - State
    struct State {
        /// 로딩창 표시 여부
        var isLoading: Bool
        /// 표시할 에러메시지
        var errorMessage: String?
        // 로그인, 회원 가입 여부에 따라 온보딩 표시 여부가 달라질 수 있어서 별개로 둠
        /// 로그인 성공
        var signinSuccess: Bool
        /// 회원가입 성공
        var signupSuccess: Bool
    }
    
    // MARK: - properties
    var accessToken: String?
    var refreshToken: String?
    
    let initialState = State(isLoading: false, signinSuccess: false, signupSuccess: false)
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .launch:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                self.processLoginFlow(),
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setLoginSuccess:
            newState.signinSuccess = true
            
        case .setSignupSuccess:
            newState.signupSuccess = true
            
        case .setError(let errorMessage):
            newState.errorMessage = errorMessage
        }
        return newState
    }

}

// MARK: - 통신 로직
extension LaunchScreenViewReactor {
    
    private func processLoginFlow() -> Observable<Mutation> {
        return networkManager.requestRSAPublicKey()
            .flatMap { publicKey in
                // Reactor 내부에 공개키 설정
                self.publicKey = publicKey
                return self.encryptDeviceId()
            }
            .flatMap { encryptedDeviceId in
                // 로그인 시도
                self.attemptLogin(with: encryptedDeviceId)
            }
            .catch { error in
                // 에러 발생 시 Mutation.setError 반환
                return Observable.just(Mutation.setError(error.localizedDescription))
            }
    }
    
}
    
extension LaunchScreenViewReactor {
    
    func reactorForMainTabBar() -> MainTabBarReactor {
        MainTabBarReactor()
    }
    
}
