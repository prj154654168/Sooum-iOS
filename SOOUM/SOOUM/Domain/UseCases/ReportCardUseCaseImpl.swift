//
//  ReportCardUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class ReportCardUseCaseImpl: ReportCardUseCase {
    
    private let repository: CardRepository
    
    init(repository: CardRepository) {
        self.repository = repository
    }
    
    func report(cardId: String, reportType: String) -> Observable<Bool> {
        
        return self.repository.reportCard(id: cardId, reportType: reportType).map { $0 == 200 }
    }
}
