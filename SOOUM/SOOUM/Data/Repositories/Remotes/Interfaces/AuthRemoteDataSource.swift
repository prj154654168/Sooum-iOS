//
//  AuthRemoteDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

import RxSwift

protocol AuthRemoteDataSource {
    
    func signUp(nickname: String, profileImageName: String?) -> Observable<Bool>
    func login() -> Observable<Bool>
    func withdraw(reaseon: String) -> Observable<Int>
}
