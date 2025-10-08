//
//  TagRemoteDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

import RxSwift

protocol TagRemoteDataSource {
    
    func related(resultCnt: Int, keyword: String) -> Observable<TagInfoResponse>
}
