//
//  CardUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 9/28/25.
//

import Foundation

import RxSwift

protocol CardUseCase {
    
    
    // MARK: Home
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<[BaseCardInfo]>
    func popularCard(latitude: String?, longitude: String?) -> Observable<[BaseCardInfo]>
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<[BaseCardInfo]>
    
    
    // MARK: Detail
    
    func detailCard(id: String, latitude: String?, longitude: String?) -> Observable<DetailCardInfo>
    func commentCard(id: String, lastId: String?, latitude: String?, longitude: String?) -> Observable<[BaseCardInfo]>
    func deleteCard(id: String) -> Observable<Bool>
    func updateLike(id: String, isLike: Bool) -> Observable<Bool>
    func updateBlocked(id: String, isBlocked: Bool) -> Observable<Bool>
    func reportCard(id: String, reportType: String) -> Observable<Bool>
    
    
    // MARK: Write
    
    func defaultImages() -> Observable<DefaultImages>
    func presignedURL() -> Observable<ImageUrlInfo>
    func uploadImage(_ data: Data, with url: URL) -> Observable<Bool>
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
    ) -> Observable<String>
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
    ) -> Observable<String>
}
