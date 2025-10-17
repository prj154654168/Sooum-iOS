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
    
    func relatedTags(keyword: String, size: Int) -> Observable<TagInfoResponse> {
        
        let request: CardRequest = .relatedTags(keyword: keyword, size: size)
        return self.provider.networkManager.perform(TagInfoResponse.self, request: request)
    }
}
