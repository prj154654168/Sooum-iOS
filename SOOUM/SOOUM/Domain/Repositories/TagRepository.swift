//
//  TagRepository.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

import RxSwift

protocol TagRepository {
    
    func relatedTags(keyword: String, size: Int) -> Observable<TagInfoResponse>
}
