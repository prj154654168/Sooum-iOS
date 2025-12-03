//
//  FetchTagUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol FetchTagUseCase: AnyObject {
    
    func related(keyword: String, size: Int) -> Observable<[TagInfo]>
    func favorites() -> Observable<[FavoriteTagInfo]>
    func ranked() -> Observable<[TagInfo]>
}
