//
//  UpdateUserInfoUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class UpdateUserInfoUseCaseImpl: UpdateUserInfoUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func updateUserInfo(nickname: String?, imageName: String?) -> Observable<Bool> {
        
        return self.repository.updateMyProfile(
            nickname: nickname,
            imageName: imageName
        )
        .map { $0 == 200 }
    }
}
