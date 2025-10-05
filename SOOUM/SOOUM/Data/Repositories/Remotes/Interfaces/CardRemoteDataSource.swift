//
//  CardRemoteDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 9/28/25.
//

import Foundation

import RxSwift

protocol CardRemoteDataSource {
    
    func latestCard(lastId: String?, latitude: String?, longitude: String?) -> Observable<HomeCardInfoResponse>
    func popularCard(latitude: String?, longitude: String?) -> Observable<HomeCardInfoResponse>
    func distanceCard(lastId: String?, latitude: String, longitude: String, distanceFilter: String) -> Observable<HomeCardInfoResponse>
}
