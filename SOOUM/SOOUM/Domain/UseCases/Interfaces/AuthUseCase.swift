//
//  AuthUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import RxSwift

protocol AuthUseCase: AnyObject {
    
    func signUp(nickname: String, profileImageName: String?) -> Observable<Bool>
    func login() -> Observable<Bool>
    func withdraw(reaseon: String) -> Observable<Bool>
    
    func encryptedDeviceId() -> Observable<String?>
    
    func initializeAuthInfo()
    func hasToken() -> Bool
    func tokens() -> Token
}
