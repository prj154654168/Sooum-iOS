//
//  DeleteCardUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class DeleteCardUseCaseImpl: DeleteCardUseCase {
    
    private let repository: CardRepository
    
    init(repository: CardRepository) {
        self.repository = repository
    }
    
    func delete(cardId: String) -> Observable<Bool> {
        
        return self.repository.deleteCard(id: cardId).map { $0 == 200 }
    }
}
