//
//  ValidateNicknameUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol ValidateNicknameUseCase: AnyObject {
    
    func nickname() -> Observable<String>
    func checkValidation(nickname: String) -> Observable<Bool>
}
