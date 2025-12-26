//
//  ErrorInterceptor.swift
//  SOOUM
//
//  Created by 오현식 on 10/27/24.
//

import Alamofire

final class ErrorInterceptor: RequestInterceptor {
    
    enum Text {
        static let networkErrorDialogTitle: String = "네트워크 상태가 불안정해요"
        static let networkErrorDialogMessage: String = "네트워크 연결상태를 확인 후 다시 시도해 주세요."
        static let confirmActionTitle: String = "확인"
        
        static let unknownErrorDialogTitle: String = "일시적인 오류가 발생했어요"
        static let unknownErrorDialogMessage: String = "같은 문제가 반복된다면 ‘문의하기'를 눌러 숨 팀에 알려주세요."
        static let closeActionButtonTitle: String = "닫기"
        static let inquiryActionTitle: String = "문의하기"
        
        static let adminMailStrUrl: String = "sooum1004@gmail.com"
        static let identificationInfo: String = "식별 정보: "
        static let inquiryMailTitle: String = "[문의하기]"
        static let inquiryMailGuideMessage: String = """
            \n
            문의 내용: 식별 정보 삭제에 주의하여 주시고, 이곳에 자유롭게 문의하실 내용을 적어주세요.
            단, 본 양식에 비방, 욕설, 허위 사실 유포 등의 부적절한 내용이 포함될 경우,
            관련 법령에 따라 민·형사상 법적 조치가 이루어질 수 있음을 알려드립니다.
        """
    }
    
    private let retryLimit: Int = 1
    
    private let provider: ManagerTypeDelegate
    
    init(provider: ManagerTypeDelegate) {
        self.provider = provider
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        
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
                completion(.doNotRetry)
                return
            }
        }
        
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        switch response.statusCode {
        /// AccessToken 재인증
        case 401:
            // 재인증 과정은 1번만 진행한다.
            guard request.retryCount < self.retryLimit else {
                let retryError = NSError(
                    domain: "SOOUM",
                    code: -99,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Retry error: ReAuthenticate process is performed only once."
                    ]
                )
                completion(.doNotRetryWithError(retryError))
                return
            }
            
            var usedToken = request.request?.value(forHTTPHeaderField: "Authorization") ?? ""
            usedToken = usedToken.replacingOccurrences(of: "Bearer ", with: "", options: .anchored)
            
            let token = self.provider.authManager.authInfo.token
            guard usedToken == token.accessToken else {
                completion(.retry)
                return
            }
            self.provider.authManager.reAuthenticate(token) { result in
                
                switch result {
                case .success:
                    completion(.retry)
                case let .failure(error):
                    Log.error("ReAuthenticate failed. \(error.localizedDescription)")
                    completion(.doNotRetry)
                }
            }
            return
        case 418:
            self.goToOnboarding()
            completion(.doNotRetry)
            return
        case 500:
            self.showUnknownErrorDialog()
            completion(.doNotRetry)
            return
        default:
            break
        }
        
        completion(.doNotRetryWithError(error))
    }
    
    
    // MARK: Error handling
    
    func showNetworkErrorDialog() {
        
        let confirmAction = SOMDialogAction(
            title: Text.confirmActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss()
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
    
    func showUnknownErrorDialog() {
        
        let closeAction = SOMDialogAction(
            title: Text.closeActionButtonTitle,
            style: .gray,
            action: {
                SOMDialogViewController.dismiss()
            }
        )
        
        let inquireAction = SOMDialogAction(
            title: Text.inquiryActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    let subject = Text.inquiryMailTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let guideMessage = """
                        \(Text.identificationInfo)
                        \(self.provider.authManager.authInfo.token.refreshToken)\n
                        \(Text.inquiryMailGuideMessage)
                    """
                    let body = guideMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let mailToString = "mailto:\(Text.adminMailStrUrl)?subject=\(subject)&body=\(body)"

                    if let mailtoUrl = URL(string: mailToString),
                       UIApplication.shared.canOpenURL(mailtoUrl) {

                        UIApplication.shared.open(mailtoUrl, options: [:], completionHandler: nil)
                    }
                }
            }
        )
        
        DispatchQueue.main.async {
            SOMDialogViewController.show(
                title: Text.unknownErrorDialogTitle,
                message: Text.unknownErrorDialogMessage,
                textAlignment: .left,
                actions: [closeAction, inquireAction]
            )
        }
    }
    
    
    // MARK: go to onboarding
    
    func goToOnboarding() {
        
        self.provider.authManager.initializeAuthInfo()
        
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let windowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window: UIWindow = windowScene.windows.first(where: { $0.isKeyWindow })
            else { return }
            
            let onBoardingViewController = OnboardingViewController()
            onBoardingViewController.reactor = OnboardingViewReactor(dependencies: appDelegate.appDIContainer)
            onBoardingViewController.modalTransitionStyle = .crossDissolve
            window.rootViewController = UINavigationController(rootViewController: onBoardingViewController)
        }
    }
}
