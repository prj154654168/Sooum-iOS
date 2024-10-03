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
    
    // TODO: - 삭제
    /// 임시 디바이스 아이디
    let deviceID = "asdawgrwasekjfhsdlkjfg"
    
    let initialState = State(isLoading: false, signinSuccess: false, signupSuccess: false)
    
    private let networkManager = NetworkManager.shared
    
    init() { }
    
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
        print("\(type(of: self)) - \(#function)")

        return fetchRSAKey()
            .flatMap { rsaKeyResponse -> Observable<String> in
                // 공개키로 기기 id 암호화
                guard let encryptedDeviceID = self.encryptDeviceID(with: rsaKeyResponse.key!.publicKey, deviceID: self.deviceID) else {
                    return Observable.error(NSError(domain: "EncryptionError", code: -1, userInfo: nil))
                }
                return Observable.just(encryptedDeviceID)
            }
            .flatMap { encryptedDeviceID -> Observable<SigninResponse> in
                // 암호화된 기기 id로 로그인 요청
                let loginRequest = SigninRequest.login(encryptedDeviceId: encryptedDeviceID)
                return self.networkManager.request(SigninResponse.self, request: loginRequest)
            }
            .flatMap { loginResponse -> Observable<Mutation> in
                if loginResponse.isRegistered {
                    // 기존 사용자 -> 로그인 성공 처리
                    self.accessToken = loginResponse.token?.accessToken
                    self.refreshToken = loginResponse.token?.refreshToken
                    return Observable.just(Mutation.setLoginSuccess)
                } else {
                    // 규 사용자 -> 회원가입 처리
                    return self.processSignupFlow()
                }
            }
            .catch { error in
                // 에러 처리
                return Observable.just(Mutation.setError(error.localizedDescription))
            }
    }
    
    /// RSA 키 fetch
    func fetchRSAKey() -> Observable<RSAKeyResponse> {
        print("\(type(of: self)) - \(#function)")

        let request = RSAKeyRequest.getPublicKey
        return networkManager.request(RSAKeyResponse.self, request: request)
    }
    
    /// 기기 id 공개키로 암호화
    func encryptDeviceID(with publicKey: String, deviceID: String) -> String? {
        print("\(type(of: self)) - \(#function)")

        // PublicKey를 Data로 변환
        guard let publicKeyData = Data(base64Encoded: publicKey) else {
            print("Invalid Public Key")
            return nil
        }

        // deviceID를 Data로 변환
        guard let deviceIDData = deviceID.data(using: .utf8) else {
            print("Invalid Device ID")
            return nil
        }

        // 3. PublicKey를 SecKey로 변환
        let keyDict: [NSObject: NSObject] = [kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                              kSecAttrKeyClass: kSecAttrKeyClassPublic]
        guard let secKey = SecKeyCreateWithData(publicKeyData as CFData, keyDict as CFDictionary, nil) else {
            print("Failed to create SecKey")
            return nil
        }

        // 4. RSA 암호화
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(secKey, .rsaEncryptionOAEPSHA256, deviceIDData as CFData, &error) else {
            print("RSA Encryption Failed: \(error.debugDescription)")
            return nil
        }

        // 5. 암호화된 데이터를 Base64로 인코딩하여 반환
        return (encryptedData as Data).base64EncodedString()
    }
    
    private func processSignupFlow() -> Observable<Mutation> {
        print("\(type(of: self)) - \(#function)")

        let request = SignupRequest.signup(
            encryptedDeviceId: self.deviceID,
            firebaseToken: "example_firebase_token",  // 실제로 사용할 Firebase 토큰
            isAllowNotify: true
//            isAllowTermOne: true,
//            isAllowTermTwo: true,
//            isAllowTermThree: true
        )
        return self.networkManager.request(SignupResponse.self, request: request)
            .flatMap { signupResponse -> Observable<Mutation> in
                // 토큰 저장
                self.accessToken = signupResponse.token.accessToken
                self.refreshToken = signupResponse.token.refreshToken
                // 회원가입 성공 처리
                return Observable.just(Mutation.setSignupSuccess)
            }
            .catch { error in
                // 에러 처리
                return Observable.just(Mutation.setError(error.localizedDescription))
            }
    }
}
    
extension LaunchScreenViewReactor {
    
    func reactorForMainTabBar() -> MainTabBarReactor {
        MainTabBarReactor()
    }
}
