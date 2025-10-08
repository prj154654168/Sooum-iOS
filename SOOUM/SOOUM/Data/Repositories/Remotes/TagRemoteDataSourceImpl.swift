//
//  TagRemoteDataSourceImpl.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

import RxSwift

class TagRemoteDataSourceImpl: TagRemoteDataSource {
    
    private let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func related(resultCnt: Int, keyword: String) -> Observable<TagInfoResponse> {
        
        let request: TagRequest = .related(resultCnt: resultCnt, keyword: keyword)
        return self.provider.networkManager.fetch(TagInfoResponse.self, request: request)
    }
}
