//
//  CardRemoteDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 9/28/25.
//

import Foundation

import RxSwift

protocol CardRemoteDataSource {
    
    
    // MARK: Home
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<BaseCardInfoResponse>
    func popularCard(latitude: String?, longitude: String?) -> Observable<BaseCardInfoResponse>
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<BaseCardInfoResponse>
    
    
    // MARK: Detail
    
    func detailCard(id: String, latitude: String?, longitude: String?) -> Observable<DetailCardInfoResponse>
    func commentCard(id: String, lastId: String?, latitude: String?, longitude: String?) -> Observable<BaseCardInfoResponse>
    func deleteCard(id: String) -> Observable<Int>
    func updateLike(id: String, isLike: Bool) -> Observable<Int>
    func updateBlocked(id: String, isBlocked: Bool) -> Observable<Int>
    func reportCard(id: String, reportType: String) -> Observable<Int>
    
    
    // MARK: Write
    
    func defaultImages() -> Observable<DefaultImagesResponse>
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
    ) -> Observable<Int>
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
    ) -> Observable<Int>
}
