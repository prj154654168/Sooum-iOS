//
//  OnboardingNicknameSettingViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/6/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


class OnboardingNicknameSettingViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "회원가입"
        
        static let title: String = "숨에서 사용할 닉네임을\n입력해주세요"
        static let guideMessage: String = "최대 8자까지 입력할 수 있어요"
        
        static let nextButtonTitle: String = "다음"
    }
    
    
    // MARK: Views

    private let guideMessageView = OnboardingGuideMessageView(title: Text.title, currentNumber: 2)
    
    private let nicknameTextField = SOMNicknameTextField()
    
    private let nextButton = SOMButton().then {
        $0.title = Text.nextButtonTitle
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
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        
        self.view.addSubview(self.guideMessageView)
        self.guideMessageView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.nicknameTextField)
        self.nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(self.guideMessageView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
        }
    }
    
    // 키보드 상태 업데이트에 따른 버튼 위치 조정
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
        
        let height = height == 0 ? 0 : height + 12
        self.nextButton.snp.updateConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-height)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: OnboardingNicknameSettingViewReactor) {
        
        // Action
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let nickname = self.nicknameTextField.textField.rx.text.orEmpty.distinctUntilChanged().share()
        nickname
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map(Reactor.Action.checkValidate)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.nextButton.rx.tap
            .subscribe(with: self) { object, _ in
                let profileImageSettingVC = OnboardingProfileImageSettingViewController()
                profileImageSettingVC.reactor = reactor.reactorForProfileImage()
                object.navigationPush(profileImageSettingVC, animated: true)
            }
            .disposed(by: self.disposeBag)

        // State
        reactor.state.map(\.nickname)
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, randomText in
                object.nicknameTextField.text = randomText
                object.nicknameTextField.textField.sendActions(for: .editingChanged)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isValid)
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.nextButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.errorMessage)
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, errorMessage in
                object.nicknameTextField.guideMessage = errorMessage == nil ? Text.guideMessage : errorMessage
                object.nicknameTextField.hasError = errorMessage != nil
            }
            .disposed(by: self.disposeBag)
    }
}
