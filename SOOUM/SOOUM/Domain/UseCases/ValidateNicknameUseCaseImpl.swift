//
//  ValidateNicknameUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class ValidateNicknameUseCaseImpl: ValidateNicknameUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func nickname() -> Observable<String> {
        
        return self.repository.nickname().map(\.nickname)
    }
    
    func checkValidation(nickname: String) -> Observable<Bool> {
        
        return self.repository.validateNickname(nickname: nickname).map(\.isAvailable)
    }
}
