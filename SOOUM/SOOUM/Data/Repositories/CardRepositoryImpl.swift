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
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<HomeCardInfoResponse> {
        
        return self.remoteDataSource.latestCard(lastId: lastId, latitude: latitude, longitude: longitude)
    }
    
    func popularCard(latitude: String?, longitude: String?) -> Observable<HomeCardInfoResponse> {
        
        return self.remoteDataSource.popularCard(latitude: latitude, longitude: longitude)
    }
    
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<HomeCardInfoResponse> {
        
        return self.remoteDataSource.distanceCard(lastId: lastId, latitude: latitude, longitude: longitude, distanceFilter: distanceFilter)
    }
}
