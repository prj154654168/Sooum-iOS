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
    
    private let provider: ManagerTypeDelegate
    
    init(provider: ManagerTypeDelegate) {
        self.provider = provider
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        self.lock.lock(); defer { self.lock.unlock() }
        
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        if response.statusCode == 401 {
            // 재인증 과정은 1번만 진행한다.
            guard request.retryCount < retryLimit else {
                completion(.doNotRetryWithError(error))
                return
            }
            
            let token = self.provider.authManager.authInfo.token
            self.provider.authManager.reAuthenticate(token) { result in
                
                switch result {
                case .success:
                    completion(.retry)
                case let .failure(error):
                    Log.error("ReAuthenticate failed. \(error.localizedDescription)")
                    completion(.doNotRetry)
                }
            }
        }
        
        if response.statusCode == 403 {
            // 온보딩 화면으로 전환
            self.goToOnboarding()
        }
        
        completion(.doNotRetryWithError(error))
    }
    
    func goToOnboarding() {
        
        self.provider.authManager.initializeAuthInfo()

        DispatchQueue.main.async {
            if let window: UIWindow = UIApplication.currentWindow,
               let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                
                let onboardingViewController = OnboardingViewController()
                onboardingViewController.reactor = OnboardingViewReactor(dependencies: appDelegate.appDIContainer)
                window.rootViewController = UINavigationController(rootViewController: onboardingViewController)
            }
        }
    }
}
