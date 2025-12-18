//
//  CompositeInterceptor.swift
//  SOOUM
//
//  Created by 오현식 on 11/4/24.
//

import Alamofire

final class CompositeInterceptor: RequestInterceptor {
    
    private let interceptors: [RequestInterceptor]
    
    private let timeoutInterval: TimeInterval = 20.0
    
    init(provider: ManagerTypeDelegate) {
        
        self.interceptors = [
            AddingTokenInterceptor(provider: provider),
            TimeoutInterceptor(timeoutInterval: self.timeoutInterval),
            ErrorInterceptor(provider: provider)
        ]
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        
        self.adapts(urlRequest, index: 0, session: session, completion: completion)
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        
        // ErrorInterceptor의 retry 적용
        if let errorInterceptor = self.interceptors.first(where: { $0 is ErrorInterceptor }) as? ErrorInterceptor {
            errorInterceptor.retry(request, for: session, dueTo: error) { result in
                completion(result)
            }
        } else {
            completion(.doNotRetryWithError(error))
        }
    }
}

private extension CompositeInterceptor {
    
    func adapts(
        _ urlRequest: URLRequest,
        index: Int,
        session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        // interceptors 갯수만큼 적용
        guard index < self.interceptors.count else {
            completion(.success(urlRequest))
            return
        }
        
        self.interceptors[index].adapt(urlRequest, for: session) { [weak self] result in
            switch result {
            case let .success(request):
                self?.adapts(request, index: index + 1, session: session, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
