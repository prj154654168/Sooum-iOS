//
//  UpdateUserInfoUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol UpdateUserInfoUseCase: AnyObject {
    
    func updateUserInfo(nickname: String?, imageName: String?) -> Observable<Bool>
}
