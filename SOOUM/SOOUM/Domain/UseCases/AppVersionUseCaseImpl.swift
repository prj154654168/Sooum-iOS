//
//  AppVersionUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import RxSwift

final class AppVersionUseCaseImpl: AppVersionUseCase {
    
    private let repository: AppVersionRepository
    
    init(repository: AppVersionRepository) {
        self.repository = repository
    }
    
    func version() -> Observable<Version> {
        
        return self.repository.version().map(\.version)
    }
}
