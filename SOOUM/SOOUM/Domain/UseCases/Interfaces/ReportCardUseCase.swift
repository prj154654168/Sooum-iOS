//
//  ReportCardUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol ReportCardUseCase: AnyObject {
    
    func report(cardId: String, reportType: String) -> Observable<Bool>
}
