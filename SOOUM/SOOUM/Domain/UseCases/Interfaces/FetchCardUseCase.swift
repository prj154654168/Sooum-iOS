//
//  FetchCardUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol FetchCardUseCase: AnyObject {
    
    /// 홈 피드 카드 조회 최신/인기/거리
    func latestCards(
        lastId: String?,
        latitude: String?,
        longitude: String?
    ) -> Observable<[BaseCardInfo]>
    func popularCards(
        latitude: String?,
        longitude: String?
    ) -> Observable<[BaseCardInfo]>
    func distanceCards(
        lastId: String?,
        latitude: String,
        longitude: String,
        distanceFilter: String
    ) -> Observable<[BaseCardInfo]>
    
    /// 마이 카드 조회 피드/댓글
    func writtenFeedCards(userId: String, lastId: String?) -> Observable<[ProfileCardInfo]>
    func writtenCommentCards(lastId: String?) -> Observable<[ProfileCardInfo]>
    
    /// 태그 태그가 포함된 카드 조회
    func cardsWithTag(
        tagId: String,
        lastId: String?
    ) -> Observable<(cardInfos: [ProfileCardInfo], isFavorite: Bool)>
}
