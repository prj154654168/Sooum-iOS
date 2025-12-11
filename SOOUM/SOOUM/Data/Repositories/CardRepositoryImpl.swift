//
//  CardRepositoryImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/28/25.
//

import Foundation

import RxSwift

class CardRepositoryImpl: CardRepository {
    
    private let remoteDataSource: CardRemoteDataSource
    
    init(remoteDataSource: CardRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    
    // MARK: Home
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<BaseCardInfoResponse> {
        
        return self.remoteDataSource.latestCard(lastId: lastId, latitude: latitude, longitude: longitude)
    }
    
    func popularCard(latitude: String?, longitude: String?) -> Observable<BaseCardInfoResponse> {
        
        return self.remoteDataSource.popularCard(latitude: latitude, longitude: longitude)
    }
    
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<BaseCardInfoResponse> {
        
        return self.remoteDataSource.distanceCard(lastId: lastId, latitude: latitude, longitude: longitude, distanceFilter: distanceFilter)
    }
    
    
    // MARK: Detail
    
    func detailCard(id: String, latitude: String?, longitude: String?) -> Observable<DetailCardInfoResponse> {
        
        return self.remoteDataSource.detailCard(id: id, latitude: latitude, longitude: longitude)
    }
    
    func isCardDeleted(id: String) -> Observable<IsCardDeletedResponse> {
        
        return self.remoteDataSource.isCardDeleted(id: id)
    }
    
    func commentCard(id: String, lastId: String?, latitude: String?, longitude: String?) -> Observable<BaseCardInfoResponse> {
        
        return self.remoteDataSource.commentCard(id: id, lastId: lastId, latitude: latitude, longitude: longitude)
    }
    
    func deleteCard(id: String) -> Observable<Int> {
        
        return self.remoteDataSource.deleteCard(id: id)
    }
    
    func updateLike(id: String, isLike: Bool) -> Observable<Int> {
        
        return self.remoteDataSource.updateLike(id: id, isLike: isLike)
    }
    
    func reportCard(id: String, reportType: String) -> Observable<Int> {
        
        return self.remoteDataSource.reportCard(id: id, reportType: reportType)
    }
    
    
    // MARK: Write
    
    func defaultImages() -> Observable<DefaultImagesResponse> {
        
        return self.remoteDataSource.defaultImages()
    }
    
    func presignedURL() -> Observable<ImageUrlInfoResponse> {
        
        return self.remoteDataSource.presignedURL()
    }
    
    func uploadImage(_ data: Data, with url: URL) -> Observable<Result<Int, Error>> {
        
        return self.remoteDataSource.uploadImage(data, with: url)
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
        
        return self.remoteDataSource.writeCard(
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
        
        return self.remoteDataSource.writeComment(
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
    }
    
    
    // MARK: Tag
    
    func tagCards(tagId: String, lastId: String?) -> Observable<TagCardInfoResponse> {
        
        return self.remoteDataSource.tagCards(tagId: tagId, lastId: lastId)
    }
    
    
    // MARK: My
    
    func feedCards(userId: String, lastId: String?) -> Observable<ProfileCardInfoResponse> {
        
        return self.remoteDataSource.feedCards(userId: userId, lastId: lastId)
    }
    
    func myCommentCards(lastId: String?) -> Observable<ProfileCardInfoResponse> {
        
        return self.remoteDataSource.myCommentCards(lastId: lastId)
    }
}
