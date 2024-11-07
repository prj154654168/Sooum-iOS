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
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    private let authManager = AuthManager.shared
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        self.lock.lock(); defer { self.lock.unlock() }
        
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        self.requestsToRetry.append(completion)
        
        self.authManager.reAuthenticate(self.authManager.authInfo.token.accessToken) { [weak self] result in
            self?.lock.lock(); defer { self?.lock.unlock() }
            
            switch result {
            case .success:
                self?.requestsToRetry.forEach { $0(.retry) }
            case .failure(let error):
                print("❌ ReAuthenticate failed. \(error.localizedDescription)")
                self?.requestsToRetry.forEach { $0(.doNotRetry) }
                self?.goBackToSignUp()
            }
            
            self?.requestsToRetry.removeAll()
        }
    }
    
    func goBackToSignUp() {
        // 로컬 token 초기화
        AuthManager.shared.initializeAuthInfo()
        // TODO: 회원가입 화면으로 전환
    }
}
