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
        
        // ErrorInterceptor의 인증헤더 적용
        self.errorInterceptor.adapt(urlRequest, for: session) { [weak self] result in
            switch result {
            case .success(let request):
                // TimeoutInterceptor 적용
                self?.timeoutInterceptor.adapt(request, for: session, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        
        // ErrorInterceptor의 retry 적용
        self.errorInterceptor.retry(request, for: session, dueTo: error) { result in
            switch result {
            case .retry:
                completion(.retry)
            default:
                completion(.doNotRetry)
            }
        }
    }
}
