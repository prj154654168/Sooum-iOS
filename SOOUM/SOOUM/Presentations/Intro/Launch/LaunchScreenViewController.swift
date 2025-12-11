//
//  LaunchScreenViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/24/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

import SnapKit
import Then


class LaunchScreenViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let updateVerionTitle: String = "업데이트 안내"
        static let updateVersionMessage: String = "새로운 버전이 출시되었습니다. 더 나은 사용을 위해, 서비스 업데이트 후 이용 바랍니다."
        
        static let testFlightStrUrl: String = "itms-beta://testflight.apple.com/v1/app"
        static let appStoreStrUrl: String = "itms-apps://itunes.apple.com/app/id"
        
        static let updateActionTitle: String = "새로워진 숨 사용하기"
    }
    
    
    // MARK: Views
    
    let imageView = UIImageView(image: .init(.logo(.v2(.logo_white)))).then {
        $0.contentMode = .scaleAspectFit
    }
    
    
    // MARK: Override func
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.isNavigationBarHidden = true
        
        self.view.backgroundColor = .som.v2.pMain
        
        self.view.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(33)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: LaunchScreenViewReactor) {
        
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.launch }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // 앱 버전 검사
        reactor.state.map(\.mustUpdate)
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                
                let updateAction = SOMDialogAction(
                    title: Text.updateActionTitle,
                    style: .primary,
                    action: {
                        SOMDialogViewController.dismiss {
                            #if DEVELOP
                            // 개발 버전일 때 testFlight로 전환
                            let strUrl = "\(Text.testFlightStrUrl)/\(Info.appId)"
                            if let testFlightUrl = URL(string: strUrl) {
                                UIApplication.shared.open(testFlightUrl, options: [:], completionHandler: nil)
                            }
                            #elseif PRODUCTION
                            // 운영 버전일 때 app store로 전환
                            let strUrl = "\(Text.appStoreStrUrl)\(Info.appId)"
                            if let appStoreUrl = URL(string: strUrl) {
                                UIApplication.shared.open(appStoreUrl, options: [:], completionHandler: nil)
                            }
                            #endif
                        }
                    }
                )
                
                SOMDialogViewController.show(
                    title: Text.updateVerionTitle,
                    message: Text.updateVersionMessage,
                    textAlignment: .left,
                    actions: [updateAction]
                )
            })
            .disposed(by: self.disposeBag)

        // 로그인 성공 시 홈 화면으로 전환
        let isRegistered = reactor.state.map(\.isRegistered).distinctUntilChanged().share()
        isRegistered
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                let viewController = MainTabBarController()
                viewController.reactor = reactor.reactorForMainTabBar()
                let navigationController = UINavigationController(
                    rootViewController: viewController
                )
                object.view.window?.rootViewController = navigationController
            }
            .disposed(by: self.disposeBag)
        // 로그인 실패 시 온보딩 화면으로 전환
        isRegistered
            .filter { $0 == false }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                let viewController = OnboardingViewController()
                viewController.reactor = reactor.reactorForOnboarding()
                let navigationController = UINavigationController(
                    rootViewController: viewController
                )
                object.view.window?.rootViewController = navigationController
            }
            .disposed(by: self.disposeBag)
    }
}
