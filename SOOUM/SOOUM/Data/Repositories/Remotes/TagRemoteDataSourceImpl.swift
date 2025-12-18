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
    
    func related(keyword: String, size: Int) -> Observable<TagInfoResponse> {
        
        let request: TagRequest = .related(keyword: keyword, size: size)
        return self.provider.networkManager.perform(TagInfoResponse.self, request: request)
    }
    
    func favorites() -> Observable<FavoriteTagInfoResponse> {
        
        let request: TagRequest = .favorites
        return self.provider.networkManager.fetch(FavoriteTagInfoResponse.self, request: request)
    }
    
    func updateFavorite(tagId: String, isFavorite: Bool) -> Observable<Int> {
        
        let request: TagRequest = .updateFavorite(tagId: tagId, isFavorite: isFavorite)
        return self.provider.networkManager.perform(request)
    }
    
    func ranked() -> Observable<TagInfoResponse> {
        
        let request: TagRequest = .ranked
        return self.provider.networkManager.fetch(TagInfoResponse.self, request: request)
    }
}
