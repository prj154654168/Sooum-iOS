//
//  AppVersionUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import RxSwift

protocol AppVersionUseCase: AnyObject {
    
    func version() -> Observable<Version>
}
