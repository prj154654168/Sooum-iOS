//
//  OnboardingTermsOfServiceViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/6/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift


class OnboardingTermsOfServiceViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "회원가입"
        
        static let guideMessageTitle: String = "숨 서비스 이용을 위해\n동의해주세요"
        
        static let termsOfSeviceUrlString: String = "https://mewing-space-6d3.notion.site/3f92380d536a4b569921d2809ed147ef?pvs=4"
        static let locationServiceUrlString: String = "https://mewing-space-6d3.notion.site/45d151f68ba74b23b24483ad8b2662b4?pvs=4"
        static let privacyPolicyUrlString: String = "https://mewing-space-6d3.notion.site/44e378c9d11d45159859492434b6b128?pvs=4"
        
        static let nextButtonTitle: String = "다음"
    }
    
    enum TermsOfService: CaseIterable {
        
        case termsOfService
        case locationService
        case privacyPolicy
        
        var text: String {
            switch self {
            case .termsOfService:
                "[필수] 서비스 이용 약관"
            case .locationService:
                "[필수] 위치정보 이용 약관"
            case .privacyPolicy:
                "[필수] 개인정보 처리 방침"
            }
        }
        
        var url: URL {
            switch self {
            case .termsOfService:
                return URL(string: Text.termsOfSeviceUrlString)!
            case .locationService:
                return URL(string: Text.locationServiceUrlString)!
            case .privacyPolicy:
                return URL(string: Text.privacyPolicyUrlString)!
            }
        }
    }
    
    
    // MARK: Views
    
    private let guideMessageView = OnboardingGuideMessageView(
        title: Text.guideMessageTitle,
        currentNumber: 1
    )
    
    private let agreeAllButtonView = TermsOfServiceAgreeButtonView()
    
    private let termsOfServiceCellView = TermsOfServiceCellView(title: TermsOfService.termsOfService.text)
    private let locationServiceCellView = TermsOfServiceCellView(title: TermsOfService.locationService.text)
    private let privacyPolicyCellView = TermsOfServiceCellView(title: TermsOfService.privacyPolicy.text)
    
    private let nextButton = SOMButton().then {
        $0.title = Text.nextButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.white
        $0.backgroundColor = .som.v2.black
        $0.isEnabled = false
    }
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + next button height + padding
        return 34 + 56 + 8
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
        
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.guideMessageView)
        self.guideMessageView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.agreeAllButtonView)
        self.agreeAllButtonView.snp.makeConstraints {
            $0.top.equalTo(self.guideMessageView.snp.bottom).offset(32)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.termsOfServiceCellView)
        self.termsOfServiceCellView.snp.makeConstraints {
            $0.top.equalTo(self.agreeAllButtonView.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.locationServiceCellView)
        self.locationServiceCellView.snp.makeConstraints {
            $0.top.equalTo(self.termsOfServiceCellView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.privacyPolicyCellView)
        self.privacyPolicyCellView.snp.makeConstraints {
            $0.top.equalTo(self.locationServiceCellView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: OnboardingTermsOfServiceViewReactor) {
        
        // Action
        self.agreeAllButtonView.rx.didSelect
            .map { _ in Reactor.Action.allAgree }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.termsOfServiceCellView.rx.didSelect
            .map { _ in Reactor.Action.termsOfServiceAgree }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.termsOfServiceCellView.rx.moveSelect
            .subscribe(onNext: { _ in
                if UIApplication.shared.canOpenURL(TermsOfService.termsOfService.url) {
                    UIApplication.shared.open(
                        TermsOfService.termsOfService.url,
                        options: [:],
                        completionHandler: nil
                    )
                }
            })
            .disposed(by: self.disposeBag)
        
        self.locationServiceCellView.rx.didSelect
            .map { _ in Reactor.Action.locationAgree }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.locationServiceCellView.rx.moveSelect
            .subscribe(onNext: { _ in
                if UIApplication.shared.canOpenURL(TermsOfService.locationService.url) {
                    UIApplication.shared.open(
                        TermsOfService.locationService.url,
                        options: [:],
                        completionHandler: nil
                    )
                }
            })
            .disposed(by: self.disposeBag)
        
        self.privacyPolicyCellView.rx.didSelect
            .map { _ in Reactor.Action.privacyPolicyAgree }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.privacyPolicyCellView.rx.moveSelect
            .subscribe(onNext: { _ in
                if UIApplication.shared.canOpenURL(TermsOfService.privacyPolicy.url) {
                    UIApplication.shared.open(
                        TermsOfService.privacyPolicy.url,
                        options: [:],
                        completionHandler: nil
                    )
                }
            })
            .disposed(by: self.disposeBag)
        
        self.nextButton.rx.tap
            .subscribe(with: self) { object, _ in
                let nicknameSettingVC = OnboardingNicknameSettingViewController()
                nicknameSettingVC.reactor = reactor.reactorForNickname()
                object.navigationPush(nicknameSettingVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map(\.isAllAgreed)
            .distinctUntilChanged()
            .subscribe(with: self) { object, isAllAgreed in
                object.agreeAllButtonView.updateState(isAllAgreed, animated: false)
                object.nextButton.isEnabled = isAllAgreed
            }
            .disposed(by: self.disposeBag)

        reactor.state.map(\.isTermsOfServiceAgreed)
            .distinctUntilChanged()
            .subscribe(with: self) { object, isTermsOfServiceAgreed in
                object.termsOfServiceCellView.updateState(isTermsOfServiceAgreed, animated: false)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isLocationAgreed)
            .distinctUntilChanged()
            .subscribe(with: self) { object, isLocationAgreed in
                object.locationServiceCellView.updateState(isLocationAgreed, animated: false)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isPrivacyPolicyAgreed)
            .distinctUntilChanged()
            .subscribe(with: self) { object, isPrivacyPolicyAgreed in
                object.privacyPolicyCellView.updateState(isPrivacyPolicyAgreed, animated: false)
            }
            .disposed(by: self.disposeBag)
    }
}
