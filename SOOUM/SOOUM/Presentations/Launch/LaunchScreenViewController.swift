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


class LaunchScreenViewController: BaseViewController, View {
    
    enum Text {
        static let updateVerionTitle: String = "업데이트 안내"
        static let updateVersionMessage: String = "안정적인 서비스 사용을 위해\n최신버전으로 업데이트해주세요"
        
        static let testFlightStrUrl: String = "itms-beta://testflight.apple.com/v1/app"
    }
    
    let viewForAnimation = UIView().then {
        $0.backgroundColor = UIColor(hex: "#A2E3FF")
    }
    
    let imageView = UIImageView(image: .init(.logo)).then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .som.white
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func setupConstraints() {
        self.view.backgroundColor = UIColor(hex: "#A2E3FF")
        
        self.view.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(self.view.safeAreaLayoutGuide.snp.centerY)
            $0.width.equalTo(235)
            $0.height.equalTo(45)
        }
        
        self.view.addSubview(self.viewForAnimation)
        self.viewForAnimation.snp.makeConstraints {
            $0.edges.equalTo(self.imageView)
        }
    }
    
    func bind(reactor: LaunchScreenViewReactor) {
        
        // 애니메이션이 끝나면 launch action
        self.rx.viewDidLayoutSubviews
            .subscribe(with: self) { object, _ in
                object.animate(to: 45) { _ in
                    reactor.action.onNext(.launch)
                }
            }
            .disposed(by: self.disposeBag)
        
        // 앱 버전 검사
        reactor.state.map(\.mustUpdate)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                
                SOMDialogViewController.show(
                    title: Text.updateVerionTitle,
                    subTitle: Text.updateVersionMessage,
                    leftAction: .init(
                        mode: .exit,
                        handler: {
                            // 앱 종료
                            // 자연스럽게 종료하기 위해 종료전, suspend 상태로 변경 후 종료
                            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                exit(0)
                            }
                        }
                    ),
                    rightAction: .init(
                        mode: .update,
                        handler: {
                            #if DEVELOP
                            // 개발 버전일 때 testFlight로 전환
                            let strUrl = "\(Text.testFlightStrUrl)/\(Info.appId)"
                            if let testFlightUrl = URL(string: strUrl) {
                                UIApplication.shared.open(testFlightUrl, options: [:], completionHandler: nil)
                            }
                            #endif
                            
                            UIApplication.topViewController?.dismiss(animated: true)
                        }
                    )
                )
            }
            .disposed(by: self.disposeBag)

        // 로그인 성공 시 홈 화면으로 전환
        let isRegistered = reactor.state.map(\.isRegistered).share()
        isRegistered
            .filter { $0 }
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
            .subscribe(with: self) { object, _ in
                let viewController = OnboardingViewController()
                let navigationController = UINavigationController(
                    rootViewController: viewController
                )
                object.view.window?.rootViewController = navigationController
            }
            .disposed(by: self.disposeBag)
    }
    
    private func animate(to height: CGFloat, completion: @escaping ((Bool) -> Void)) {
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.2,
            options: [.beginFromCurrentState, .curveEaseOut],
            animations: {
                self.viewForAnimation.transform = .init(translationX: 0, y: height)
            },
            completion: completion
        )
    }
}
