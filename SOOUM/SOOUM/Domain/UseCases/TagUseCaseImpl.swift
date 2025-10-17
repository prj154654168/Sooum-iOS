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
    
    func relatedTags(keyword: String, size: Int) -> Observable<[TagInfo]> {
        
        return self.repository.relatedTags(keyword: keyword, size: size).map { $0.tagInfos }
    }
}
