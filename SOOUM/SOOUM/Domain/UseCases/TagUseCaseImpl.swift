//
//  TagUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

import RxSwift

class TagUseCaseImpl: TagUseCase {
    
    private let repository: TagRepository
    
    init(repository: TagRepository) {
        self.repository = repository
    }
    
    func related(keyword: String, size: Int) -> Observable<[TagInfo]> {
        
        return self.repository.related(keyword: keyword, size: size).map { $0.tagInfos }
    }
    
    func favorites() -> Observable<[FavoriteTagInfo]> {
        
        return self.repository.favorites().map(\.tagInfos)
    }
    
    func updateFavorite(tagId: String, isFavorite: Bool) -> Observable<Bool> {
        
        return self.repository.updateFavorite(tagId: tagId, isFavorite: isFavorite).map { $0 == 200 }
    }
    
    func ranked() -> Observable<[TagInfo]> {
        
        return self.repository.ranked().map(\.tagInfos)
    }
    
    func tagCards(tagId: String, lastId: String?) -> Observable<(cardInfos: [ProfileCardInfo], isFavorite: Bool)> {
        
        return self.repository.tagCards(tagId: tagId, lastId: lastId).map { ($0.cardInfos, $0.isFavorite) }
    }
}
