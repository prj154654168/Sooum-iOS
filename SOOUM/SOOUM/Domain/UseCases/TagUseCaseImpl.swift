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
    
    func related(resultCnt: Int, keyword: String) -> Observable<[TagInfo]> {
        
        return self.repository.related(resultCnt: resultCnt, keyword: keyword).map { $0.tagInfos }
    }
}
