//
//  EnterMemberTransferViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


class EnterMemberTransferViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "내 계정 가져오기"
        
        static let title: String = "기존 계정이 있으신가요?"
        
        static let placeholderText: String = "코드 입력"
        static let textfieldGuideMessage: String = "코드는 발급 후 24시간 동안 유효해요"
        
        static let guideTitle: String = "내 계정 가져오기 안내"
        static let guideMessage: String = "기존 휴대폰의 숨 앱 [설정>내 계정 내보내기]에서 발급한 코드를 입력하면, 기존 계정을 현재 휴대폰에서 그대로 사용할 수 있어요"
        
        static let dialogTitle: String = "유효하지 않은 코드예요"
        static let dialogMessage: String = "코드를 확인한 뒤 다시 시도해주세요."
        static let dialogConfirmButtonTitle: String = "확인"
        
        static let confirmButtonTitle: String = "확인"
    }
    
    private let titleLabel = UILabel().then {
        $0.text = Text.title
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.head2
    }
    
    private let transferTextField = EnterMemberTransferTextFieldView().then {
        $0.placeholder = Text.placeholderText
        $0.guideMessage = Text.textfieldGuideMessage
    }
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }
    
    private let confirmButton = SOMButton().then {
        $0.title = Text.confirmButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.white
        $0.backgroundColor = .som.v2.black
        $0.isEnabled = false
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.transferTextField)
        self.transferTextField.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
        }
        
        let guideTitleView = UIView()
        let guideTitleImageView = UIImageView().then {
            $0.image = .init(.icon(.v2(.filled(.info))))
            $0.tintColor = .som.v2.black
        }
        let guideTitleLabel = UILabel().then {
            $0.text = Text.guideTitle
            $0.textColor = .som.v2.black
            $0.typography = .som.v2.subtitle2
        }
        guideTitleView.addSubview(guideTitleImageView)
        guideTitleImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.size.equalTo(16)
        }
        guideTitleView.addSubview(guideTitleLabel)
        guideTitleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(guideTitleImageView.snp.trailing).offset(6)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        let guideMessageLabel = UILabel().then {
            $0.text = Text.guideMessage
            $0.textColor = .som.v2.gray500
            $0.typography = .som.v2.caption2.withAlignment(.left)
            $0.numberOfLines = 0
            $0.lineBreakMode = .byCharWrapping
        }
        
        let guideView = UIView().then {
            $0.backgroundColor = .som.v2.pLight1
            $0.layer.cornerRadius = 10
        }
        guideView.addSubview(guideTitleView)
        guideTitleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        guideView.addSubview(guideMessageLabel)
        guideMessageLabel.snp.makeConstraints {
            $0.top.equalTo(guideTitleView.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-14)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        self.container.addArrangedSubview(guideView)
        
        self.confirmButton.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        self.container.addArrangedSubview(self.confirmButton)
        
        self.view.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
        
        let margin: CGFloat = height + 12
        self.container.snp.updateConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-margin)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: EnterMemberTransferViewReactor) {
        
        // Action
        let transferCode = self.transferTextField.rx.text.orEmpty.distinctUntilChanged()
        transferCode
            .map { $0.isEmpty == false }
            .bind(to: self.confirmButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap
            .withLatestFrom(transferCode)
            .map(Reactor.Action.enterTransferCode)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        let isSuccess = reactor.state.map(\.isSuccess).distinctUntilChanged().share()
        
        isSuccess
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                let launchScreenViewController = LaunchScreenViewController()
                launchScreenViewController.reactor = reactor.reactorForLaunch()
                object.view.window?.rootViewController = launchScreenViewController
            }
            .disposed(by: self.disposeBag)
        
        isSuccess
            .filter { $0 == false }
            .subscribe(onNext: { _ in
                let confirmAction = SOMDialogAction(
                    title: Text.dialogConfirmButtonTitle,
                    style: .primary,
                    action: {
                        UIApplication.topViewController?.dismiss(animated: true)
                    }
                )
                
                SOMDialogViewController.show(
                    title: Text.dialogTitle,
                    message: Text.dialogMessage,
                    textAlignment: .left,
                    actions: [confirmAction]
                )
            })
            .disposed(by: self.disposeBag)
    }
}

extension EnterMemberTransferViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
