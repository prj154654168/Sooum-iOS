//
//  FetchTagUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class FetchTagUseCaseImpl: FetchTagUseCase {
    
    private let repository: TagRepository
    
    init(repository: TagRepository) {
        self.repository = repository
    }
    
    func related(keyword: String, size: Int) -> Observable<[TagInfo]> {
        
        return self.repository.related(keyword: keyword, size: size).map(\.tagInfos)
    }
    
    func favorites() -> Observable<[FavoriteTagInfo]> {
        
        return self.repository.favorites().map(\.tagInfos)
    }
    
    func ranked() -> Observable<[TagInfo]> {
        
        return self.repository.ranked().map(\.tagInfos)
    }
}
