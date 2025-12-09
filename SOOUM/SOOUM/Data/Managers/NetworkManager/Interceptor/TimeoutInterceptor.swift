//
//  TimeoutInterceptor.swift
//  SOOUM
//
//  Created by 오현식 on 11/4/24.
//

import Alamofire

final class TimeoutInterceptor: RequestInterceptor {
    
    private let timeoutInterval: TimeInterval
    
    init(timeoutInterval: TimeInterval) {
        self.timeoutInterval = timeoutInterval
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var request = urlRequest
        request.timeoutInterval = self.timeoutInterval
        completion(.success(request))
    }
}
