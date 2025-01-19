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
        static let guideMessageTitle: String = "숨을 시작하기 위해서는\n약관 동의가 필요해요"
        
        static let confirmButtonTitle: String = "확인"
    }
    
    
    // MARK: Views
    
    private let guideMessageView = OnboardingGuideMessageView(title: Text.guideMessageTitle)
    
    private let agreeAllButtonView = TermsOfServiceAgreeButtonView()
    
    private let termsOfServiceCellView = TermsOfServiceCellView(title: TermsOfService.termsOfService.text)
    private let locationServiceCellView = TermsOfServiceCellView(title: TermsOfService.locationService.text)
    private let privacyPolicyCellView = TermsOfServiceCellView(title: TermsOfService.privacyPolicy.text)
    
    private let nextButton = SOMButton().then {
        $0.title = Text.confirmButtonTitle
        $0.typography = .som.body1WithBold
        $0.foregroundColor = .som.gray600
        
        $0.backgroundColor = .som.gray300
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    
    // MARK: Override func
        
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.guideMessageView)
        self.guideMessageView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(28)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        self.view.addSubview(self.agreeAllButtonView)
        self.agreeAllButtonView.snp.makeConstraints {
            $0.top.equalTo(self.guideMessageView.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(60)
        }
        
        self.view.addSubview(self.termsOfServiceCellView)
        self.termsOfServiceCellView.snp.makeConstraints {
            $0.top.equalTo(self.agreeAllButtonView.snp.bottom).offset(36)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.locationServiceCellView)
        self.locationServiceCellView.snp.makeConstraints {
            $0.top.equalTo(self.termsOfServiceCellView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.privacyPolicyCellView)
        self.privacyPolicyCellView.snp.makeConstraints {
            $0.top.equalTo(self.locationServiceCellView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: OnboardingTermsOfServiceViewReactor) {
        
        // Action
        self.agreeAllButtonView.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.allAgree }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.termsOfServiceCellView.rx.didSelect
            .map { _ in Reactor.Action.termsOfServiceAgree }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.termsOfServiceCellView.rx.nextSelect
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
        
        self.locationServiceCellView.rx.nextSelect
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
        
        self.privacyPolicyCellView.rx.nextSelect
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
            .map { _ in Reactor.Action.signUp }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map(\.shouldNavigate)
            .filter { $0 }
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
                object.agreeAllButtonView.updateState(isAllAgreed)
                
                object.nextButton.foregroundColor = isAllAgreed ? .som.white : .som.gray600
                object.nextButton.backgroundColor = isAllAgreed ? .som.p300 : .som.gray300
                object.nextButton.isEnabled = isAllAgreed
            }
            .disposed(by: self.disposeBag)

        reactor.state.map(\.isTermsOfServiceAgreed)
            .distinctUntilChanged()
            .subscribe(with: self) { object, isTermsOfServiceAgreed in
                object.termsOfServiceCellView.updateState(isTermsOfServiceAgreed)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isLocationAgreed)
            .distinctUntilChanged()
            .subscribe(with: self) { object, isLocationAgreed in
                object.locationServiceCellView.updateState(isLocationAgreed)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isPrivacyPolicyAgreed)
            .distinctUntilChanged()
            .subscribe(with: self) { object, isPrivacyPolicyAgreed in
                object.privacyPolicyCellView.updateState(isPrivacyPolicyAgreed)
            }
            .disposed(by: self.disposeBag)
    }
}
