//
//  TagRemoteDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import RxSwift

protocol TagRemoteDataSource {
    
    func related(keyword: String, size: Int) -> Observable<TagInfoResponse>
    func favorites() -> Observable<FavoriteTagInfoResponse>
    func updateFavorite(tagId: String, isFavorite: Bool) -> Observable<Int>
    func ranked() -> Observable<TagInfoResponse>
    func tagCards(tagId: String, lastId: String?) -> Observable<TagCardInfoResponse>
}
