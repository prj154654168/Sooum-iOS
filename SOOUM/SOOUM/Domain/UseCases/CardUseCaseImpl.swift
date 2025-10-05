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
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<[BaseCardInfo]> {

        return self.repository.latestCard(lastId: lastId, latitude: latitude, longitude: longitude).map { $0.cardInfos }
    }
    
    func popularCard(latitude: String?, longitude: String?) -> Observable<[BaseCardInfo]> {
    
        return self.repository.popularCard(latitude: latitude, longitude: longitude).map { $0.cardInfos }
    }
    
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<[BaseCardInfo]> {
        
        return self.repository.distanceCard(lastId: lastId, latitude: latitude, longitude: longitude, distanceFilter: distanceFilter).map { $0.cardInfos }
    }
}
