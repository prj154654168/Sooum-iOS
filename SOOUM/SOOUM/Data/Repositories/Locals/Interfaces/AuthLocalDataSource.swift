//
//  AuthLocalDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import RxSwift

protocol AuthLocalDataSource {
    
    func initializeAuthInfo()
    func hasToken() -> Bool
    func tokens() -> Token
    func encryptedDeviceId() -> Observable<String?>
}
