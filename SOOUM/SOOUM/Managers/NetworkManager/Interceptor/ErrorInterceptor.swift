//
//  ErrorInterceptor.swift
//  SOOUM
//
//  Created by 오현식 on 10/27/24.
//

import Foundation

import Alamofire


class ErrorInterceptor: RequestInterceptor {
    
    private let lock = NSLock()
    
    private let retryLimit: Int = 1
    
    private let authManager = AuthManager.shared
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        self.lock.lock(); defer { self.lock.unlock() }
        
        guard let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401
        else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        // 재인증 과정은 1번만 진행한다.
        guard request.retryCount < retryLimit else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        self.authManager.reAuthenticate(self.authManager.authInfo.token.accessToken) { result in
            
            switch result {
            case .success:
                completion(.retry)
            case .failure(let error):
                Log.error("ReAuthenticate failed. \(error.localizedDescription)")
                completion(.doNotRetry)
            }
        }
    }
}
