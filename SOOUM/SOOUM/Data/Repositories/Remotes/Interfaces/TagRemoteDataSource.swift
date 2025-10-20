//
//  TagRemoteDataSource.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

import RxSwift

protocol TagRemoteDataSource {
    
    func relatedTags(keyword: String, size: Int) -> Observable<TagInfoResponse>
}
