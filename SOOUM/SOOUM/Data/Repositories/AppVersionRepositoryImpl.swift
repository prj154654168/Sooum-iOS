//
//  AppVersionRepositoryImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation

import RxSwift

class AppVersionRepositoryImpl: AppVersionRepository {
    
    private let remoteDataSource: AppVersionRemoteDataSource
    
    init(remoteDataSource: AppVersionRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func version() -> Observable<AppVersionStatusResponse> {
        
        return self.remoteDataSource.version()
    }
}
