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
    
    /// 관심 태그는 최대 9개
    func favorites() -> Observable<[FavoriteTagInfo]> {
        
        return self.repository.favorites().map(\.tagInfos).map { Array($0.prefix(9)) }
    }
    
    // 인기 태그는 최소 1개 이상일 때 표시
    // 인기 태그는 최대 10개까지 표시
    func ranked() -> Observable<[TagInfo]> {
        
        return self.repository.ranked().map(\.tagInfos)
            .map { $0.filter { $0.usageCnt > 0 } }
            // 중복 제거
            // .map { Array(Set($0)) }
            // 태그 갯수로 정렬
            // .map { $0.sorted(by: { $0.usageCnt > $1.usageCnt }) }
            .map { Array($0.prefix(10)) }
    }
}
