//
//  TagUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import RxSwift

protocol TagUseCase {
    
    func related(keyword: String, size: Int) -> Observable<[TagInfo]>
    func favorites() -> Observable<[FavoriteTagInfo]>
    func updateFavorite(tagId: String, isFavorite: Bool) -> Observable<Bool>
    func ranked() -> Observable<[TagInfo]>
    func tagCards(tagId: String, lastId: String?) -> Observable<(cardInfos: [ProfileCardInfo], isFavorite: Bool)>
}
