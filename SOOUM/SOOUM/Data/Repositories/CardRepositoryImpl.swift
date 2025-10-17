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
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<HomeCardInfoResponse> {
        
        return self.remoteDataSource.latestCard(lastId: lastId, latitude: latitude, longitude: longitude)
    }
    
    func popularCard(latitude: String?, longitude: String?) -> Observable<HomeCardInfoResponse> {
        
        return self.remoteDataSource.popularCard(latitude: latitude, longitude: longitude)
    }
    
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<HomeCardInfoResponse> {
        
        return self.remoteDataSource.distanceCard(lastId: lastId, latitude: latitude, longitude: longitude, distanceFilter: distanceFilter)
    }
    
    
    // MARK: Write
    
    func defaultImages() -> Observable<DefaultImagesResponse> {
        
        return self.remoteDataSource.defaultImages()
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
}
