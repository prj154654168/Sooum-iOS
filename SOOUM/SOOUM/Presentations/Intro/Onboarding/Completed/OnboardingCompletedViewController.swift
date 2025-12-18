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
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + next button height + padding
        return 34 + 56 + 8
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
        self.confirmButton.rx.throttleTap(.seconds(3))
            .subscribe(with: self) { object, _ in
                let viewController = MainTabBarController()
                viewController.reactor = reactor.reactorForMainTabBar()
                let navigationController = UINavigationController(
                    rootViewController: viewController
                )
                object.view.window?.rootViewController = navigationController
            }
            .disposed(by: self.disposeBag)
    }
}
