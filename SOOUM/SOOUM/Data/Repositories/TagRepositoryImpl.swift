//
//  TagRepositoryImpl.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

import RxSwift

class TagRepositoryImpl: TagRepository {
    
    private let remoteDataSource: TagRemoteDataSource
    
    init(remoteDataSource: TagRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func related(keyword: String, size: Int) -> Observable<TagInfoResponse> {
        
        return self.remoteDataSource.related(keyword: keyword, size: size)
    }
    
    func favorites() -> Observable<FavoriteTagInfoResponse> {
        
        return self.remoteDataSource.favorites()
    }
    
    func updateFavorite(tagId: String, isFavorite: Bool) -> Observable<Int> {
        
        return self.remoteDataSource.updateFavorite(tagId: tagId, isFavorite: isFavorite)
    }
    
    func ranked() -> Observable<TagInfoResponse> {
        
        return self.remoteDataSource.ranked()
    }
    
    func tagCards(tagId: String, lastId: String?) -> Observable<TagCardInfoResponse> {
        
        return self.remoteDataSource.tagCards(tagId: tagId, lastId: lastId)
    }
}
