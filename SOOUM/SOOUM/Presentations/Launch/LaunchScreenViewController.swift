//
//  LaunchScreenViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/24/24.
//

import UIKit

import ReactorKit
import RxSwift

import SnapKit
import Then


class LaunchScreenViewController: BaseViewController, View {
    
    /// 런치스크린 애니메이션 완료 이벤트
    let animationCompleted = PublishSubject<Void>()
    
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
        self.rx.viewDidLoad
            .map { Reactor.Action.launch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 애니메이션이 끝나면 이벤트 방출
        self.rx.viewDidLayoutSubviews
            .subscribe(with: self) { object, _ in
                object.animate(to: 45) { _ in
                    let viewController = MainTabBarController()
                    viewController.reactor = reactor.reactorForMainTabBar()
                    let navigationController = UINavigationController(
                        rootViewController: viewController
                    )
                    object.view.window?.rootViewController = navigationController
                }
            }
            .disposed(by: self.disposeBag)

        // 애니메이션 완료 이벤트 && 로그인/회원가입 성공 시 홈 화면으로 전환
        Observable.combineLatest(
            animationCompleted, // 애니메이션 완료 시
            reactor.state.filter { $0.signinSuccess || $0.signupSuccess } // 로그인/회원가입 성공 시
        )
        .observe(on: MainScheduler.instance)
        .subscribe(with: self) { object, _ in
            let viewController = MainTabBarController()
            viewController.reactor = reactor.reactorForMainTabBar()
            object.view.window?.rootViewController = viewController
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
                self.view.layoutIfNeeded()
            },
            completion: completion
        )
    }
}
