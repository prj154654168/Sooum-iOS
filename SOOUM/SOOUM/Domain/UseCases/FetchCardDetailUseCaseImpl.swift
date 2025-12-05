//
//  FetchCardDetailUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class FetchCardDetailUseCaseImpl: FetchCardDetailUseCase {
    
    private let repository: CardRepository
    
    init(repository: CardRepository) {
        self.repository = repository
    }
    
    func detailCard(
        id: String,
        latitude: String?,
        longitude: String?
    ) -> Observable<DetailCardInfo> {
        
        return self.repository.detailCard(
            id: id,
            latitude: latitude,
            longitude: longitude
        )
        .map(\.cardInfos)
    }
    
    func commentCards(
        id: String,
        lastId: String?,
        latitude: String?,
        longitude: String?
    ) -> Observable<[BaseCardInfo]> {
        
        return self.repository.commentCard(
            id: id,
            lastId: lastId,
            latitude: latitude,
            longitude: longitude
        )
        .map(\.cardInfos)
    }
    
    func isDeleted(cardId: String) -> Observable<Bool> {
        
        return self.repository.isCardDeleted(id: cardId).map(\.isDeleted)
    }
}
