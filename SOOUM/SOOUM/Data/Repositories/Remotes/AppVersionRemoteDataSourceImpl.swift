//
//  AppVersionRemoteDataSourceImpl.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation

import RxSwift

class AppVersionRemoteDataSourceImpl: AppVersionRemoteDataSource {
    
    private let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
    
    func version() -> Observable<AppVersionStatusResponse> {
        
        return self.provider.networkManager.updateCheck()
    }
}
