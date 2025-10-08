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
}
