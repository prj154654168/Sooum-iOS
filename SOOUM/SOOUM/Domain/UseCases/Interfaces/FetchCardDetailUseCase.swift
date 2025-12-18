//
//  FetchCardDetailUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol FetchCardDetailUseCase: AnyObject {
    
    func detailCard(
        id: String,
        latitude: String?,
        longitude: String?
    ) -> Observable<DetailCardInfo>
    
    func commentCards(
        id: String,
        lastId: String?,
        latitude: String?,
        longitude: String?
    ) -> Observable<[BaseCardInfo]>
    
    func isDeleted(cardId: String) -> Observable<Bool>
}
