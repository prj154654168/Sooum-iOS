//
//  UpdateTagFavoriteUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class UpdateTagFavoriteUseCaseImpl: UpdateTagFavoriteUseCase {
    
    private let repository: TagRepository
    
    init(repository: TagRepository) {
        self.repository = repository
    }
    
    func updateFavorite(tagId: String, isFavorite: Bool) -> Observable<Bool> {
        
        return self.repository.updateFavorite(tagId: tagId, isFavorite: isFavorite).map { $0 == 200 }
    }
}
