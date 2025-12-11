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
        static let navigationTitle: String = "이전 계정 불러오기"
        
        static let transferEnterTitle: String = "기존 계정이 있으신가요?"
        static let transferEnterGuideMessage: String = "이전에 사용하던 기기에서 로그인 코드를 입력해주세요."
        
        static let placeholderText: String = "코드 입력"
        
        static let bottomGuideTitle: String = "이전 계정 불러오기란?"
        static let bottomGuideMessage: String = "기존 휴대폰의 숨 앱[설정>다른 기기에서 로그인하기]에서 발급한 코드를 입력하면, 기존 계정을 현재 휴대폰에서 그대로 사용할 수 있어요"
        
        static let dialogTitle: String = "잘못된 코드예요"
        static let dialogMessage: String = "코드를 확인한 뒤 다시 시도해주세요."
        
        static let transferSuccessDialogTitle: String = "이전 계정 불러오기 완료"
        static let transferSuccessDialogMessage: String = "이전 계정 불러오기가 성공적으로 완료되었습니다."
        
        static let confirmButtonTitle: String = "확인"
    }
    
    
    // MARK: Views
    
    private let transferEnterTitleLabel = UILabel().then {
        $0.text = Text.transferEnterTitle
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.head2
    }
    
    private let transferEnterGuideMessageLabel = UILabel().then {
        $0.text = Text.transferEnterGuideMessage
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.title2
    }
    
    private let transferTextField = EnterMemberTransferTextFieldView().then {
        $0.placeholder = Text.placeholderText
    }
    
    private let bottomContainer = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 16
    }
    
    private let confirmButton = SOMButton().then {
        $0.title = Text.confirmButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.white
        
        $0.backgroundColor = .som.v2.black
        $0.isEnabled = false
    }
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + confirm button height + padding
        return 34 + 56 + 8
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.transferEnterTitleLabel)
        self.transferEnterTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.transferEnterGuideMessageLabel)
        self.transferEnterGuideMessageLabel.snp.makeConstraints {
            $0.top.equalTo(self.transferEnterTitleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.transferTextField)
        self.transferTextField.snp.makeConstraints {
            $0.top.equalTo(self.transferEnterGuideMessageLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
        }
        
        let guideTitleView = UIView()
        let guideTitleImageView = UIImageView().then {
            $0.image = .init(.icon(.v2(.filled(.info))))
            $0.tintColor = .som.v2.black
        }
        let guideTitleLabel = UILabel().then {
            $0.text = Text.bottomGuideTitle
            $0.textColor = .som.v2.black
            $0.typography = .som.v2.subtitle3
        }
        guideTitleView.addSubview(guideTitleImageView)
        guideTitleImageView.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.size.equalTo(16)
        }
        guideTitleView.addSubview(guideTitleLabel)
        guideTitleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalTo(guideTitleImageView.snp.trailing).offset(6)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        let guideMessageLabel = UILabel().then {
            $0.text = Text.bottomGuideMessage
            $0.textColor = .som.v2.gray500
            $0.typography = .som.v2.caption2.withAlignment(.left)
            $0.numberOfLines = 0
            $0.lineBreakMode = .byCharWrapping
            $0.lineBreakStrategy = .hangulWordPriority
        }
        
        let guideView = UIView().then {
            $0.backgroundColor = .som.v2.pLight1
            $0.layer.cornerRadius = 10
        }
        
        self.bottomContainer.addArrangedSubview(guideView)
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
        
        self.bottomContainer.addArrangedSubview(self.confirmButton)
        self.confirmButton.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        self.view.addSubview(self.bottomContainer)
        self.bottomContainer.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
        
        let margin: CGFloat = height + 12
        self.bottomContainer.snp.updateConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-margin)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: EnterMemberTransferViewReactor) {
        
        // Action
        let transferCode = self.transferTextField.rx.text.orEmpty.distinctUntilChanged().share()
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
        let isSuccess = reactor.state.map(\.isSuccess).filterNil().share()
        isSuccess
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                guard let window = object.view.window else { return }
                
                object.showSuccessDialog {
                    
                    let launchScreenViewController = LaunchScreenViewController()
                    launchScreenViewController.reactor = reactor.reactorForLaunchScreen()
                    launchScreenViewController.modalTransitionStyle = .crossDissolve
                    window.rootViewController = launchScreenViewController
                }
            }
            .disposed(by: self.disposeBag)
        
        isSuccess
            .filter { $0 == false }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                object.showErrorDialog()
            }
            .disposed(by: self.disposeBag)
    }
}

extension EnterMemberTransferViewController {
    
    func showErrorDialog() {
        
        let confirmAction = SOMDialogAction(
            title: Text.confirmButtonTitle,
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
    }
    
    func showSuccessDialog(completion: @escaping (() -> Void)) {
        
        let confirmAction = SOMDialogAction(
            title: Text.confirmButtonTitle,
            style: .primary,
            action: {
                UIApplication.topViewController?.dismiss(animated: true) { completion() }
            }
        )
        
        SOMDialogViewController.show(
            title: Text.transferSuccessDialogTitle,
            message: Text.transferSuccessDialogMessage,
            textAlignment: .left,
            actions: [confirmAction]
        )
    }
}
