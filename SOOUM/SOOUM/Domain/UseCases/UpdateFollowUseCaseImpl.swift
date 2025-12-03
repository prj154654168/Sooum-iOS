//
//  UpdateFollowUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class UpdateFollowUseCaseImpl: UpdateFollowUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func updateFollowing(userId: String, isFollow: Bool) -> Observable<Bool> {
        
        return self.repository.updateFollowing(userId: userId, isFollow: isFollow).map { $0 == 200 }
    }
}
