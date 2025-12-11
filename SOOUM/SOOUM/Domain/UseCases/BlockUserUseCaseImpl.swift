//
//  BlockUserUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class BlockUserUseCaseImpl: BlockUserUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func updateBlocked(userId: String, isBlocked: Bool) -> Observable<Bool> {
        
        return self.repository.updateBlocked(id: userId, isBlocked: isBlocked).map { $0 == 200 }
    }
}
