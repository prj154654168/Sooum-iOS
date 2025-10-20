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
    
    func relatedTags(keyword: String, size: Int) -> Observable<TagInfoResponse> {
        
        return self.remoteDataSource.relatedTags(keyword: keyword, size: size)
    }
}
