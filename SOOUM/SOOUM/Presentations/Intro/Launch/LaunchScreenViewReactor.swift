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
        case appFlag(Bool)
    }
    
    struct State {
        fileprivate(set) var mustUpdate: Bool
        /// deviceId 서버 등록 여부, 로그인 성공 여부
        fileprivate(set) var isRegistered: Bool?
        fileprivate(set) var appFlag: Bool?
    }
    
    var initialState: State = .init(
        mustUpdate: false,
        isRegistered: nil
    )
    
    // TODO: 임시, 추후 Coordinator 패턴 적용 후 필요한 UseCase만 사용
    private let dependencies: AppDIContainerable
    private let authUseCase: AuthUseCase
    private let versionUseCase: AppVersionUseCase
    
    private let pushInfo: NotificationInfo?
    
    init(dependencies: AppDIContainerable, pushInfo: NotificationInfo? = nil) {
        self.dependencies = dependencies
        self.authUseCase = dependencies.rootContainer.resolve(AuthUseCase.self)
        self.versionUseCase = dependencies.rootContainer.resolve(AppVersionUseCase.self)
        
        self.pushInfo = pushInfo
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .launch:
            // 계정 이관에 성공했을 때, 온보딩 화면으로 전환
            let isTransfered = self.pushInfo?.isTransfered ?? false
            if isTransfered {
                self.authUseCase.initializeAuthInfo()
                return .just(.updateIsRegistered(false))
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            } else {
                return self.check()
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .check(mustUpdate):
            newState.mustUpdate = mustUpdate
            
        case let .updateIsRegistered(isRegistered):
            newState.isRegistered = isRegistered
            
        case let .appFlag(appFlag):
            newState.appFlag = appFlag
        }
        return newState
    }
}


// MARK: - 통신 로직

extension LaunchScreenViewReactor {
    
    private func login() -> Observable<Mutation> {
        return self.authUseCase.login()
            .map { .updateIsRegistered($0) }
            .catch(self.catchClosure)
    }
    
    private func check() -> Observable<Mutation> {
        
        #if PRODUCTION
        return self.versionUseCase.oldVersion()
            .withUnretained(self)
            .flatMapLatest { object, version -> Observable<Mutation> in
                
                UserDefaults.standard.set(version.shouldHideTransfer, forKey: "AppFlag")
                
                if version.mustUpdate {
                    return .just(.check(true))
                } else {
                    return object.authUseCase.hasToken() ? .just(.updateIsRegistered(true)) : object.login()
                }
            }
        #elseif DEVELOP
        return self.versionUseCase.version()
            .withUnretained(self)
            .flatMapLatest { object, version -> Observable<Mutation> in
                
                UserDefaults.standard.set(version.shouldHideTransfer, forKey: "AppFlag")
                
                if version.mustUpdate {
                    return .just(.check(true))
                } else {
                    return object.authUseCase.hasToken() ? .just(.updateIsRegistered(true)) : object.login()
                }
            }
        #endif
    }
}

private extension LaunchScreenViewReactor {
    
    private var catchClosure: ((Error) throws -> Observable<Mutation> ) {
        return { error in
            
            let nsError = error as NSError
            return nsError.code == 404 ? .just(.updateIsRegistered(false)) : .empty()
        }
    }
}

extension LaunchScreenViewReactor {
    
    func reactorForOnboarding() -> OnboardingViewReactor {
        OnboardingViewReactor(dependencies: self.dependencies)
    }
    
    func reactorForMainTabBar() -> MainTabBarReactor {
        MainTabBarReactor(dependencies: self.dependencies)
    }
}
