//
//  AppVersionRepository.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation

import RxSwift

protocol AppVersionRepository {
    
    func version() -> Observable<AppVersionStatusResponse>
}
