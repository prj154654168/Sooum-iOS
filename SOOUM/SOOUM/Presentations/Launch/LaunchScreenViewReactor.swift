//
//  LaunchScreenViewReactor.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/24.
//

import Foundation
import Security

import ReactorKit

/*
 1. 어플 실행
 2. 키체인에 token 정보가 존재하는 지 확인
    - token 정보가 있다면 메인 홈으로 진입
    - token 정보가 없다면
        2.1. RSA 공개 키 요청
        2.2. deviceID 암호화
        2.3. 로그인 요청
            - deviceId가 서버에 등록되어 있다면, (isRegistered == true)
                2.1.1. 로그인 요청 후 메인 홈으로 진입
            - deviceId가 서버에 등록되어 있지 않다면, (isRegistered == false)
                2.1.3. 회원가입 요청 후 메인 홈으로 진입
 */
class LaunchScreenViewReactor: Reactor {
    
    // MARK: - Action
    enum Action: Equatable {
        /// 앱이 시작되었을 때, 로그인 및 회원가입 처리 흐름을 시작
        case launch
    }
    
    enum Mutation {
        case check(Bool)
        case updateIsRegistered(Bool)
    }
    
    struct State {
        var mustUpdate: Bool
        /// deviceId 서버 등록 여부, 로그인 성공 여부
        var isRegistered: Bool?
    }
    
    var initialState: State = .init(
        mustUpdate: false,
        isRegistered: nil
    )
    
    private let networkManager = NetworkManager.shared
    private let authManager = AuthManager.shared
    
    let pushInfo: NotificationInfo?
    
    init(pushInfo: NotificationInfo? = nil) {
        self.pushInfo = pushInfo
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .launch:
            return self.check()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .check(mustUpdate):
            newState.mustUpdate = mustUpdate
        case let .updateIsRegistered(isRegistered):
            newState.isRegistered = isRegistered
        }
        return newState
    }
}


// MARK: - 통신 로직

extension LaunchScreenViewReactor {
    
    private func login() -> Observable<Mutation> {
        return self.authManager.certification()
            .map { .updateIsRegistered($0) }
    }
    
    private func check() -> Observable<Mutation> {
        
        return self.networkManager.checkClientVersion()
            .withUnretained(self)
            .flatMapLatest { object, currentVersion -> Observable<Mutation> in
                let model = Version(currentVerion: currentVersion)
                if model.mustUpdate {
                    return .just(.check(true))
                } else {
                    return self.authManager.hasToken ? .just(.updateIsRegistered(true)) : object.login()
                }
            }
    }
}
    
extension LaunchScreenViewReactor {
    
    func reactorForMainTabBar() -> MainTabBarReactor {
        MainTabBarReactor(pushInfo: self.pushInfo)
    }
}
