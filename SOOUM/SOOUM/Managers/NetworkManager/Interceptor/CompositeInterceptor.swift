//
//  CompositeInterceptor.swift
//  SOOUM
//
//  Created by 오현식 on 11/4/24.
//

import Foundation

import Alamofire


class CompositeInterceptor: RequestInterceptor {
    
    private let errorInterceptor: ErrorInterceptor
    private let timeoutInterceptor: TimeoutInterceptor
    
    private let timeoutInterval: TimeInterval = 20.0
    
    init() {
        self.errorInterceptor = ErrorInterceptor()
        self.timeoutInterceptor = TimeoutInterceptor(timeoutInterval: self.timeoutInterval)
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        
        self.timeoutInterceptor.adapt(urlRequest, for: session, completion: completion)
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        
        // ErrorInterceptor의 retry 적용
        self.errorInterceptor.retry(request, for: session, dueTo: error) { result in
            switch result {
            case .retry:
                completion(.retry)
            default:
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
