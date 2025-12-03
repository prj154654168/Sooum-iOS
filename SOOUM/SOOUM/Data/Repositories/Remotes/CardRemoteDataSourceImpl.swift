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
    
    func reportCard(id: String, reportType: String) -> Observable<Int> {
        
        let request: CardRequest = .reportCard(id: id, reportType: reportType)
        return self.provider.networkManager.perform(request)
    }
    
    
    // MARK: Write
    
    func defaultImages() -> Observable<DefaultImagesResponse> {
        
        let request: CardRequest = .defaultImages
        return self.provider.networkManager.fetch(DefaultImagesResponse.self, request: request)
    }
    
    func presignedURL() -> Observable<ImageUrlInfoResponse> {
        
        let request: CardRequest = .presignedURL
        return self.provider.networkManager.fetch(ImageUrlInfoResponse.self, request: request)
    }
    
    func uploadImage(_ data: Data, with url: URL) -> Observable<Result<Int, Error>> {
        
        return self.provider.networkManager.upload(data, to: url)
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
    ) -> Observable<WriteCardResponse> {
        
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
        return self.provider.networkManager.perform(WriteCardResponse.self, request: request)
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
    ) -> Observable<WriteCardResponse> {
        
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
        return self.provider.networkManager.perform(WriteCardResponse.self, request: request)
    }
    
    
    // MARK: Tag
    
    func tagCards(tagId: String, lastId: String?) -> Observable<TagCardInfoResponse> {
        
        let requset: TagRequest = .tagCards(tagId: tagId, lastId: lastId)
        return self.provider.networkManager.fetch(TagCardInfoResponse.self, request: requset)
    }
    
    
    // MARK: My
    
    func feedCards(userId: String, lastId: String?) -> Observable<ProfileCardInfoResponse> {
        
        let request: UserRequest = .feedCards(userId: userId, lastId: lastId)
        return self.provider.networkManager.fetch(ProfileCardInfoResponse.self, request: request)
    }
    
    func myCommentCards(lastId: String?) -> Observable<ProfileCardInfoResponse> {
        
        let request: UserRequest = .myCommentCards(lastId: lastId)
        return self.provider.networkManager.fetch(ProfileCardInfoResponse.self, request: request)
    }
}
