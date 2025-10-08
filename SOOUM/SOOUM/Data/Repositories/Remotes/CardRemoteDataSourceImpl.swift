//
//  CardRemoteDataSourceImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/28/25.
//

import Foundation

import RxSwift

class CardRemoteDataSourceImpl: CardRemoteDataSource {
    
    private let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    
    // MARK: Home
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<HomeCardInfoResponse> {
        
        let request: CardRequest = .latestCard(lastId: lastId, latitude: latitude, longitude: longitude)
        return self.provider.networkManager.fetch(HomeCardInfoResponse.self, request: request)
    }
    
    func popularCard(latitude: String?, longitude: String?) -> Observable<HomeCardInfoResponse> {
        
        let request: CardRequest = .popularCard(latitude: latitude, longitude: longitude)
        return self.provider.networkManager.fetch(HomeCardInfoResponse.self, request: request)
    }
    
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<HomeCardInfoResponse> {
        
        let request: CardRequest = .distancCard(lastId: lastId, latitude: latitude, longitude: longitude, distanceFilter: distanceFilter)
        return self.provider.networkManager.fetch(HomeCardInfoResponse.self, request: request)
    }
    
    
    // MARK: Write
    
    func defaultImages() -> Observable<DefaultImagesResponse> {
        
        let request: CardRequest = .defaultImages
        return self.provider.networkManager.fetch(DefaultImagesResponse.self, request: request)
    }
    
    func writeCard(
        isDistanceShared: Bool,
        latitude: String?,
        longitude: String?,
        content: String,
        font: String,
        imgType: String,
        imgName: String,
        isStory: Bool,
        tags: [String]?
    ) -> Observable<Int> {
        
        let request: CardRequest = .writeCard(
            isDistanceShared: isDistanceShared,
            latitude: latitude,
            longitude: longitude,
            content: content,
            font: font,
            imgType: imgType,
            imgName: imgName,
            isStory: isStory,
            tags: tags
        )
        return self.provider.networkManager.perform(Int.self, request: request)
    }
}
