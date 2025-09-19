//
//  NetworkManager_Version.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation

import Alamofire
import RxSwift


// MARK: Version

extension NetworkManager {
    
    func version() -> Observable<Result<AppVersionStatusResponse, Error>> {
        
        let request = VersionRequest.version
        return self.fetch(AppVersionStatusResponse.self, request: request)
            .map { return .success($0) }
            .catch { return .just(.failure($0)) }
            .observe(on: MainScheduler.instance)
    }
    
    func updateCheck() -> Observable<AppVersionStatusResponse> {
        return self.version().map { (try? $0.get()) ?? AppVersionStatusResponse.emptyValue() }
    }
}
