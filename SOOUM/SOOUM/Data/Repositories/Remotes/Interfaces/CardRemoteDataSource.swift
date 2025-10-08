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
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<HomeCardInfoResponse>
    func popularCard(latitude: String?, longitude: String?) -> Observable<HomeCardInfoResponse>
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<HomeCardInfoResponse>
    
    
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
        tags: [String]?
    ) -> Observable<Int>
}
