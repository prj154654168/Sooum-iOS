//
//  TagRepository.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

import RxSwift

protocol TagRepository {
    
    func related(resultCnt: Int, keyword: String) -> Observable<TagInfoResponse>
}
