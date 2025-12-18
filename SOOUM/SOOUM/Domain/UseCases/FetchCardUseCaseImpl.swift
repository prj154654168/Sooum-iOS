//
//  FetchCardUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class FetchCardUseCaseImpl: FetchCardUseCase {
    
    private let repository: CardRepository
    
    init(repository: CardRepository) {
        self.repository = repository
    }
    
    /// 홈 피드 카드 조회 최신/인기/거리
    func latestCards(
        lastId: String?,
        latitude: String?,
        longitude: String?
    ) -> Observable<[BaseCardInfo]> {
        
        return self.repository.latestCard(
            lastId: lastId,
            latitude: latitude,
            longitude: longitude
        )
        .map(\.cardInfos)
    }
    
    func popularCards(
        latitude: String?,
        longitude: String?
    ) -> Observable<[BaseCardInfo]> {
        
        return self.repository.popularCard(
            latitude: latitude,
            longitude: longitude
        )
        .map(\.cardInfos)
    }
    
    func distanceCards(
        lastId: String?,
        latitude: String,
        longitude: String,
        distanceFilter: String
    ) -> Observable<[BaseCardInfo]> {
        
        return self.repository.distanceCard(
            lastId: lastId,
            latitude: latitude,
            longitude: longitude,
            distanceFilter: distanceFilter
        )
        .map(\.cardInfos)
    }
    
    /// 마이 카드 조회 피드/댓글
    func writtenFeedCards(userId: String, lastId: String?) -> Observable<[ProfileCardInfo]> {
        
        return self.repository.feedCards(userId: userId, lastId: lastId).map(\.cardInfos)
    }
    
    func writtenCommentCards(lastId: String?) -> Observable<[ProfileCardInfo]> {
        
        return self.repository.myCommentCards(lastId: lastId).map(\.cardInfos)
    }
    
    /// 태그 태그가 포함된 카드 조회
    func cardsWithTag(
        tagId: String,
        lastId: String?
    ) -> Observable<(cardInfos: [ProfileCardInfo], isFavorite: Bool)> {
        
        return self.repository.tagCards(
            tagId: tagId,
            lastId: lastId
        )
        .map { ($0.cardInfos, $0.isFavorite) }
    }
}
