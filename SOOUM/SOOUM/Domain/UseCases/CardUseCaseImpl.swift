//
//  CardUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/28/25.
//

import Foundation

import RxSwift

class CardUseCaseImpl: CardUseCase {
    
    private let repository: CardRepository
    
    init(repository: CardRepository) {
        self.repository = repository
    }
    
    
    // MARK: Home
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<[BaseCardInfo]> {

        return self.repository.latestCard(lastId: lastId, latitude: latitude, longitude: longitude).map { $0.cardInfos }
    }
    
    func popularCard(latitude: String?, longitude: String?) -> Observable<[BaseCardInfo]> {
    
        return self.repository.popularCard(latitude: latitude, longitude: longitude).map { $0.cardInfos }
    }
    
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<[BaseCardInfo]> {
        
        return self.repository.distanceCard(lastId: lastId, latitude: latitude, longitude: longitude, distanceFilter: distanceFilter).map { $0.cardInfos }
    }
    
    
    // MARK: Detail
    
    func detailCard(id: String, latitude: String?, longitude: String?) -> Observable<DetailCardInfo> {
        
        return self.repository.detailCard(id: id, latitude: latitude, longitude: longitude).map { $0.cardInfos }
    }
    
    func commentCard(id: String, lastId: String?, latitude: String?, longitude: String?) -> Observable<[BaseCardInfo]> {
        
        return self.repository.commentCard(id: id, lastId: lastId, latitude: latitude, longitude: longitude).map { $0.cardInfos }
    }
    
    func deleteCard(id: String) -> Observable<Bool> {
        
        return self.repository.deleteCard(id: id).map { $0 == 200 }
    }
    
    func updateLike(id: String, isLike: Bool) -> Observable<Bool> {
        
        return self.repository.updateLike(id: id, isLike: isLike).map { $0 == 200 }
    }
    
    func updateBlocked(id: String, isBlocked: Bool) -> Observable<Bool> {
        
        return self.repository.updateBlocked(id: id, isBlocked: isBlocked).map { $0 == 200 }
    }
    
    func reportCard(id: String, reportType: String) -> Observable<Bool> {
        
        return self.repository.reportCard(id: id, reportType: reportType).map { $0 == 200 }
    }
    
    
    // MARK: Write
    
    func defaultImages() -> Observable<DefaultImages> {
        
        return self.repository.defaultImages().map { $0.defaultImages }
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
    ) -> Observable<Bool> {
        
        return self.repository.writeCard(
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
        .map { $0 == 200 }
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
    ) -> Observable<Bool> {
        
        return self.repository.writeComment(
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
        .map { $0 == 200 }
    }
}
