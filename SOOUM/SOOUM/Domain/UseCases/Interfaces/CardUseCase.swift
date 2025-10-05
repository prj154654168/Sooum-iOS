//
//  CardUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 9/28/25.
//

import Foundation

import RxSwift

protocol CardUseCase {
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<[BaseCardInfo]>
    func popularCard(latitude: String?, longitude: String?) -> Observable<[BaseCardInfo]>
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<[BaseCardInfo]>
}
