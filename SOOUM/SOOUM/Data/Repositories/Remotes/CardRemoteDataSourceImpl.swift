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
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<BaseCardInfoResponse> {
        
        let request: CardRequest = .latestCard(lastId: lastId, latitude: latitude, longitude: longitude)
        return self.provider.networkManager.fetch(BaseCardInfoResponse.self, request: request)
    }
    
    func popularCard(latitude: String?, longitude: String?) -> Observable<BaseCardInfoResponse> {
        
        let request: CardRequest = .popularCard(latitude: latitude, longitude: longitude)
        return self.provider.networkManager.fetch(BaseCardInfoResponse.self, request: request)
    }
    
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<BaseCardInfoResponse> {
        
        let request: CardRequest = .distancCard(lastId: lastId, latitude: latitude, longitude: longitude, distanceFilter: distanceFilter)
        return self.provider.networkManager.fetch(BaseCardInfoResponse.self, request: request)
    }
    
    
    // MARK: Detail
    
    func detailCard(id: String, latitude: String?, longitude: String?) -> Observable<DetailCardInfoResponse> {
        
        let requset: CardRequest = .detailCard(id: id, latitude: latitude, longitude: longitude)
        return self.provider.networkManager.fetch(DetailCardInfoResponse.self, request: requset)
    }
    
    func commentCard(id: String, lastId: String?, latitude: String?, longitude: String?) -> Observable<BaseCardInfoResponse> {
        
        let request: CardRequest = .commentCard(id: id, lastId: lastId, latitude: latitude, longitude: longitude)
        return self.provider.networkManager.fetch(BaseCardInfoResponse.self, request: request)
    }
    
    func deleteCard(id: String) -> Observable<Int> {
        
        let request: CardRequest = .deleteCard(id: id)
        return self.provider.networkManager.perform(request)
    }
    
    func updateLike(id: String, isLike: Bool) -> Observable<Int> {
        
        let request: CardRequest = .updateLike(id: id, isLike: isLike)
        return self.provider.networkManager.perform(request)
    }
    
    func updateBlocked(id: String, isBlocked: Bool) -> Observable<Int> {
        
        let request: CardRequest = .updateBlocked(id: id, isBlocked: isBlocked)
        return self.provider.networkManager.perform(request)
    }
    
    func reportCard(id: String, reportType: String) -> Observable<Int> {
        
        let request: CardRequest = .reportCard(id: id, reportType: reportType)
        return self.provider.networkManager.perform(request)
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
        tags: [String]
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
        return self.provider.networkManager.perform(request)
    }
    
    func writeComment(
        id: String,
        isDistanceShared: Bool,
        latitude: String?,
        longitude: String?,
        content: String,
        font: String,
        imgType: String,
        imgName: String,
        tags: [String]
    ) -> Observable<Int> {
        
        let request: CardRequest = .writeComment(
            id: id,
            isDistanceShared: isDistanceShared,
            latitude: latitude,
            longitude: longitude,
            content: content,
            font: font,
            imgType: imgType,
            imgName: imgName,
            tags: tags
        )
        return self.provider.networkManager.perform(request)
    }
}
