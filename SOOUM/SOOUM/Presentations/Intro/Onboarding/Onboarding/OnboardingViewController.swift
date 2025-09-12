//
//  OnboardingViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/7/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

class OnboardingViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let guideTitle: String = "숨겨진 진심이 모이는 공간"
        static let guideSubTitle: String = "당신의 이야기를 편하게 남겨요"
        
        static let firstGuideMessage: String = "숨은 가입 시 어떤 개인정보도 요구하지 않아요"
        static let secondGuideMessage: String = "자동으로 추천되는 닉네임으로 5초면 가입해요"
        static let thirdGuideMessage: String = "익명으로 솔직한 이야기를 나눠요"
        
        static let startButtonTitle: String = "숨 시작하기"
        static let oldUserButtontitle: String = "기존 계정이 있으신가요?"
        
        static let banUserDialogTitle: String = "가입할 수 없는 계정이에요"
        static let banUserDialogLeadingMessage: String = "이 계정은 정지된 이력이 있습니다. 새 계정은 "
        
        static let resignDialogTitle: String = "최근 탈퇴한 계정이에요"
        static let resignDialogLeadingMessage: String = "탈퇴일로부터 7일 후 새 계정을 만들 수 있습니다. 새 계정은 "
        
        static let dialogTrailingMessage: String = "부터 만들 수 있습니다."
        
        static let confirmActionTitle: String = "확인"
    }
    
    
    // MARK: Views
    
    private let guideTitleLabel = UILabel().then {
        $0.text = Text.guideTitle
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.head1
    }
    
    private let guideSubTitleLabel = UILabel().then {
        $0.text = Text.guideSubTitle
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.title2
    }
    
    private let onboardingImageView = UIImageView().then {
        $0.image = .init(.image(.v2(.onboarding)))
        $0.contentMode = .scaleAspectFit
    }
    
    private let guideMessageContainer = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 6
    }
    
    private let startButton = SOMButton().then {
        $0.title = Text.startButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.white
        $0.backgroundColor = .som.v2.black
    }
    
    private let oldUserButton = SOMButton().then {
        $0.title = Text.oldUserButtontitle
        $0.typography = .som.v2.body1
        $0.foregroundColor = .som.v2.gray500
        $0.hasUnderlined = true
        $0.inset = .init(top: 6, left: 16, bottom: 6, right: 16)
    }
    
    
    // MARK: Override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupGuideMessage([
            Text.firstGuideMessage,
            Text.secondGuideMessage,
            Text.thirdGuideMessage
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isNavigationBarHidden = true
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.guideTitleLabel)
        self.guideTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(60)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.guideSubTitleLabel)
        self.guideSubTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.guideTitleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.onboardingImageView)
        self.onboardingImageView.snp.makeConstraints {
            $0.top.equalTo(self.guideSubTitleLabel.snp.bottom).offset(80)
            $0.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.guideMessageContainer)
        self.guideMessageContainer.snp.makeConstraints {
            $0.top.equalTo(self.onboardingImageView.snp.bottom).offset(60)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.oldUserButton)
        self.oldUserButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.startButton)
        self.startButton.snp.makeConstraints {
            $0.bottom.equalTo(self.oldUserButton.snp.top).offset(-14)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: OnboardingViewReactor) {
        
        // Action
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.reset }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Navigation
        self.startButton.rx.tap
            .map { _ in Reactor.Action.check }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.oldUserButton.rx.tap
            .subscribe(with: self) { object, _ in
              let enterMemberTransferViewController = EnterMemberTransferViewController()
              enterMemberTransferViewController.reactor = reactor.reactorForEnterTransfer()
              object.navigationPush(enterMemberTransferViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map(\.suspension)
            .filterNil()
            .subscribe(with: self) { object, suspension in
                let dialogLeadingMessage = suspension.isBanUser ? Text.banUserDialogLeadingMessage : Text.resignDialogLeadingMessage
                let dialogMessage = dialogLeadingMessage + suspension.untilBan.banEndFormatted + Text.dialogTrailingMessage
                
                let confirmAction = SOMDialogAction(
                    title: Text.confirmActionTitle,
                    style: .primary,
                    action: {
                        UIApplication.topViewController?.dismiss(animated: true)
                    }
                )
                
                SOMDialogViewController.show(
                    title: suspension.isBanUser ? Text.banUserDialogTitle : Text.resignDialogTitle,
                    message: dialogMessage,
                    textAlignment: .left,
                    actions: [confirmAction]
                )
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.shouldNavigate)
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                let termsOfServiceViewController = OnboardingTermsOfServiceViewController()
                termsOfServiceViewController.reactor = reactor.reactorForTermsOfService()
                object.navigationPush(termsOfServiceViewController, animated: true)
            }
            .disposed(by: self.disposeBag)
      
        reactor.state.map(\.shouldHideTransfer)
            .subscribe(with: self) { object, shouldHide in
                object.oldUserButton.isHidden = shouldHide
            }
            .disposed(by: self.disposeBag)
    }
}

extension OnboardingViewController {
    
    func setupGuideMessage(_ messages: [String]) {
        
        messages.forEach { message in
            
            let imageView = UIImageView().then {
                $0.image = .init(.image(.v2(.check_square_light)))
                $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            }
            
            let label = UILabel().then {
                $0.text = message
                $0.textColor = .som.v2.gray400
                $0.typography = .som.v2.body1
                $0.textAlignment = .left
            }
            
            let container = UIStackView(arrangedSubviews: [imageView, label]).then {
                $0.axis = .horizontal
                $0.spacing = 8
            }
            container.snp.makeConstraints {
                $0.height.equalTo(24)
            }
            
            self.guideMessageContainer.addArrangedSubview(container)
        }
    }
}
