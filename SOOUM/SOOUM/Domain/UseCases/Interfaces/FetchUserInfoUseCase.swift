//
//  FetchUserInfoUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol FetchUserInfoUseCase: AnyObject {
    
    func myRole() -> Observable<UserRole>
    func userInfo(userId: String?) -> Observable<ProfileInfo>
    func myNickname() -> Observable<String>
    func notify() -> Observable<PushNotiStatusInfo>
}
