//
//  UpdateCardLikeUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class UpdateCardLikeUseCaseImpl: UpdateCardLikeUseCase {
    
    private let repository: CardRepository
    
    init(repository: CardRepository) {
        self.repository = repository
    }
    
    func updateLike(cardId: String, isLike: Bool) -> Observable<Bool> {
        
        return self.repository.updateLike(id: cardId, isLike: isLike).map { $0 == 200 }
    }
}
