//
//  ErrorInterceptor.swift
//  SOOUM
//
//  Created by 오현식 on 10/27/24.
//

import Alamofire

class ErrorInterceptor: RequestInterceptor {
    
    enum Text {
        static let networkErrorDialogTitle: String = "네트워크 상태가 불안정해요"
        static let networkErrorDialogMessage: String = "네트워크 연결상태를 확인 후 다시 시도해 주세요."
        static let confirmActionTitle: String = "확인"
    }
    
    private let lock = NSLock()
    
    private let retryLimit: Int = 1
    
    private let provider: ManagerTypeDelegate
    
    init(provider: ManagerTypeDelegate) {
        self.provider = provider
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        self.lock.lock(); defer { self.lock.unlock() }
        
        /// API 호출 중 네트워크 오류 발생
        if let afError = error.asAFError,
           case let .sessionTaskFailed(underlyingError) = afError,
           let urlError = underlyingError as? URLError {
            
            let networkErrors = [
                URLError.timedOut,
                URLError.notConnectedToInternet,
                URLError.networkConnectionLost,
                URLError.cannotConnectToHost
            ]
            if networkErrors.contains(urlError.code) {
                self.showNetworkErrorDialog()
                completion(.doNotRetryWithError(error))
                return
            }
        }
        
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        /// AccessToken 재인증
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
        /// RefrehsToken 블랙리스트 (계정 이관 혹은 차단/신고 당한 계정)
        if response.statusCode == 403 {
            
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
    
    func showNetworkErrorDialog() {
        
        let confirmAction = SOMDialogAction(
            title: Text.confirmActionTitle,
            style: .primary,
            action: {
                UIApplication.topViewController?.dismiss(animated: true)
            }
        )
        
        DispatchQueue.main.async {
            SOMDialogViewController.show(
                title: Text.networkErrorDialogTitle,
                message: Text.networkErrorDialogMessage,
                textAlignment: .left,
                actions: [confirmAction]
            )
        }
    }
}
