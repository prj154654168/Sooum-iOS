//
//  OnboardingCompletedViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/25.
//

import UIKit

import ReactorKit

import SnapKit
import Then

class OnboardingCompletedViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let title: String = "가입 완료"
        static let message: String = "숨에 오신 걸 환영해요"
        
        static let confirmButtonTitle: String = "확인"
    }
    
    
    // MARK: Views
    
    private let imageView = UIImageView().then {
        $0.image = .init(.image(.v2(.onboarding_finish)))
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.text = Text.title
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.title2
    }
    
    private let messageLabel = UILabel().then {
        $0.text = Text.message
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.head1
    }
    
    private let confirmButton = SOMButton().then {
        $0.title = Text.confirmButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.white
        $0.backgroundColor = .som.v2.black
    }
    
    
    // MARK: Override func
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.isNavigationBarHidden = true
        
        let container = UIStackView(arrangedSubviews: [
            self.imageView,
            self.titleLabel,
            self.messageLabel
        ]).then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.setCustomSpacing(32, after: self.imageView)
            $0.setCustomSpacing(4, after: self.titleLabel)
        }
        self.view.addSubview(container)
        container.snp.makeConstraints {
            $0.centerY.equalTo(self.view.safeAreaLayoutGuide.snp.centerY).offset(-56)
            $0.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.confirmButton)
        self.confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: OnboardingCompletedViewReactor) {
        
        // Action
        self.confirmButton.rx.throttleTap
            .subscribe(with: self) { object, _ in
                
                // TODO: 임시, 토큰 정보 삭제 후 계정 삭제
                let withdrawAction = SOMDialogAction(
                    title: "계정 삭제하기",
                    style: .primary,
                    action: {
                        
                        UIApplication.topViewController?.dismiss(animated: true) {
                            reactor.action.onNext(.withdraw)
                        }
                    }
                )
                
                SOMDialogViewController.show(
                    title: "온보딩/회원가입 플로우 완료",
                    message: "생성된 계정 정보를 삭제하고 다시 스플레쉬 화면부터 시작합니다.",
                    textAlignment: .left,
                    actions: [withdrawAction]
                )
                
                // let viewController = MainTabBarController()
                // viewController.reactor = reactor.reactorForMainTabBar()
                // let navigationController = UINavigationController(
                //     rootViewController: viewController
                // )
                // // 제스처 뒤로가기를 위한 델리게이트 설정
                // navigationController.interactivePopGestureRecognizer?.delegate = self
                // object.view.window?.rootViewController = navigationController
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isSuccess)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                let viewController = LaunchScreenViewController()
                viewController.reactor = reactor.reaactorForLaunch()
                object.view.window?.rootViewController = viewController
            }
            .disposed(by: self.disposeBag)
    }
}
