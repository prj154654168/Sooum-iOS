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
        static let guideText: String = "당신의 소중한 이야기를\n익명의 친구들에게 들려주세요"
        static let startButtonText: String = "숨 시작하기"
        static let oldUserButtonText: String = "기존 계정이 있으신가요?"
        
        static let banUserDialogTitle: String = "기존 정지된 계정으로\n가입이 불가능 합니다."
        static let resignDialogTitle: String = "최근 탈퇴한 이력이 있습니다."
        
        static let confirmActionTitle: String = "확인"
    }
    
    
    // MARK: Views
    
    private let backgroundImageView = UIImageView().then {
        $0.image = .init(.image(.login))
        $0.contentMode = .scaleAspectFill
    }
    
    private let guideLabel = UILabel().then {
        $0.text = Text.guideText
        $0.textColor = .som.p300
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 22, weight: .semibold),
            lineHeight: 35,
            letterSpacing: 0.05,
            alignment: .left
        )
        $0.numberOfLines = 0
    }
    
    private let startButton = SOMButton().then {
        $0.title = Text.startButtonText
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 16, weight: .heavy),
            lineHeight: 20,
            letterSpacing: 0.05
        )
        $0.foregroundColor = .som.white
        
        $0.backgroundColor = .som.p300
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let oldUserButton = SOMButton().then {
        $0.title = Text.oldUserButtonText
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 14, weight: .bold),
            lineHeight: 20,
            letterSpacing: 0.05
        )
        $0.foregroundColor = UIColor(hex: "#B4B4B4")
        $0.hasUnderlined = true
    }
    
    
    // MARK: Override func
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.isNavigationBarHidden = true
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.backgroundImageView)
        self.backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.guideLabel)
        self.guideLabel.snp.makeConstraints {
            /// 실 기기 높이 * 0.6
            $0.top.equalToSuperview().offset(UIScreen.main.bounds.height * 0.6)
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.view.addSubview(self.startButton)
        self.startButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-128)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(56)
        }
        
        self.view.addSubview(self.oldUserButton)
        self.oldUserButton.snp.makeConstraints {
            $0.top.equalTo(self.startButton.snp.bottom).offset(21)
            $0.centerX.equalToSuperview()
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
            .distinctUntilChanged()
            .subscribe(with: self) { object, suspension in
                let dialogMessageView = DialogMessageView(
                    isBanUser: suspension.isBanUser,
                    banDateString: suspension.untilBan.banEndFormatted
                )
                
                let confirmAction = SOMDialogAction(
                    title: Text.confirmActionTitle,
                    style: .primary,
                    action: {
                        UIApplication.topViewController?.dismiss(animated: true)
                    }
                )
                
                SOMDialogViewController.show(
                    title: suspension.isBanUser ? Text.banUserDialogTitle : Text.resignDialogTitle,
                    messageView: dialogMessageView,
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
    }
}
