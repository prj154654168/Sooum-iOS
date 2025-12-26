//
//  ResignViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift

class ResignViewController: BaseNavigationViewController, View {

    enum Text {
        static let navigationTitle: String = "탈퇴하기"
        
        static let placeholderText: String = "계정을 삭제하려는 이유를 알려주세요"
        
        static let resignGuideMessage: String = "탈퇴하려는 이유가 무엇인가요?"
        static let resignButtonTitle: String = "탈퇴하기"
        
        static let successDialogTitle: String = "탈퇴 완료"
        static let successDialogMessage: String = "탈퇴 처리가 성공적으로 완료되었습니다."
        static let confirmActionTitle: String = "확인"
    }
    
    
    // MARK: Views
    
    private let scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let resignGuideMessage = UILabel().then {
        $0.text = Text.resignGuideMessage
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.head2.withAlignment(.left)
    }
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    private let resignTextField = ResignTextFieldView().then {
        $0.placeholder = Text.placeholderText
        $0.isHidden = true
    }
    
    private let resignButton = SOMButton().then {
        $0.title = Text.resignButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.white
        
        $0.backgroundColor = .som.v2.black
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        
        $0.isEnabled = false
    }
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + resign button height + padding
        return 34 + 56 + 8
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.resignButton)
        self.resignButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
        }
        
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(self.resignButton.snp.top).offset(-16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        let guideContainer = UIView()
        guideContainer.addSubview(self.resignGuideMessage)
        self.resignGuideMessage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.horizontalEdges.equalToSuperview()
        }
        self.scrollView.addSubview(guideContainer)
        guideContainer.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.top.equalTo(guideContainer.snp.bottom).offset(16)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        self.setupReportButtons()
    }
    
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
        
        let height = height == 0 ? 0 : height + 12
        
        self.resignButton.snp.updateConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-height)
        }
        
        guard height > 0 else { return }
        
        let contentHeight = self.scrollView.contentSize.height
        let boundsHeight = self.scrollView.bounds.height - height
        let bottomOffset = CGPoint(x: 0, y: contentHeight - boundsHeight + 10)
        // 키보드 및 스크롤 애니메이션 동기화를 위해 `UIView.animate` 사용
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.view.layoutIfNeeded()
            
            // 스크롤이 필요할 때만 적용
            if bottomOffset.y > 0 {
                self?.scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: ResignViewReactor) {
        
        // Action
        let reason = self.resignTextField.rx.text.orEmpty.distinctUntilChanged()
        reason
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map(Reactor.Action.updateOtherReason)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        reason
            .map { $0.isEmpty == false }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.resignButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.resignButton.rx.throttleTap(.seconds(3))
            .map { _ in Reactor.Action.resign }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.isSuccess)
            .distinctUntilChanged()
            .filterNil()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                guard let window = object.view.window else { return }
                
                object.showSuccessReportedDialog {
                    
                    let onboardingViewController = OnboardingViewController()
                    onboardingViewController.reactor = reactor.reactorForOnboarding()
                    onboardingViewController.modalTransitionStyle = .crossDissolve
                    
                    let navigationViewController = UINavigationController(rootViewController: onboardingViewController)
                    window.rootViewController = navigationViewController
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.reason)
            .distinctUntilChanged()
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, reason in
                
                let items = object.container.arrangedSubviews.compactMap { $0 as? SOMButton }
                
                items.forEach { item in
                    item.isSelected = reason.identifier == item.tag
                }
                
                if reason != .other {
                    object.resignButton.isEnabled = true
                }
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: setup buttons and show dialog

private extension ResignViewController {
    
    func setupReportButtons() {
        
        guard let reactor = self.reactor else { return }
        
        WithdrawType.allCases.forEach { withdrawType in
            
            let item = SOMButton().then {
                
                $0.title = withdrawType.message
                $0.typography = .som.v2.subtitle1
                $0.foregroundColor = .som.v2.gray600
                $0.backgroundColor = .som.v2.gray100
                
                $0.inset = .init(top: 0, left: 16, bottom: 0, right: 0)
                $0.contentHorizontalAlignment = .left
                
                $0.tag = withdrawType.identifier
            }
            item.snp.makeConstraints {
                $0.width.equalTo(UIScreen.main.bounds.width - 16 * 2)
                $0.height.equalTo(48)
            }
            item.rx.throttleTap
                .subscribe(with: self) { object, _ in
                    
                    object.resignTextField.isHidden = withdrawType != .other
                    if withdrawType == .other {
                        object.resignTextField.becomeFirstResponder()
                    } else {
                        object.resignTextField.resignFirstResponder()
                    }
                    reactor.action.onNext(.updateReason(withdrawType))
                }
                .disposed(by: self.disposeBag)
            
            self.container.addArrangedSubview(item)
        }
        
        self.container.addArrangedSubview(self.resignTextField)
    }
    
    func showSuccessReportedDialog(completion: @escaping (() -> Void)) {
        
        let confirmAction = SOMDialogAction(
            title: Text.confirmActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss { completion() }
            }
        )

        SOMDialogViewController.show(
            title: Text.successDialogTitle,
            message: Text.successDialogMessage,
            textAlignment: .left,
            actions: [confirmAction]
        )
    }
}
