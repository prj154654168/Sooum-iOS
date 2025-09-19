//
//  AppVersionUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation

import RxSwift

class AppVersionUseCaseImpl: AppVersionUseCase {
    
    private let repository: AppVersionRepository
    
    init(repository: AppVersionRepository) {
        self.repository = repository
    }
    
    func version() -> Observable<Version> {
        
        return self.repository.version().map { $0.version }
    }
    
    func oldVersion() -> Observable<Version> {
        
        return self.repository.oldVersion().map { Version(status: $0) }
    }
}
