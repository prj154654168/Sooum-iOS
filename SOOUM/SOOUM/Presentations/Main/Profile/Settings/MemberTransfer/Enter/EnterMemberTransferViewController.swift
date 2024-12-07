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
        static let navigationTitle: String = "계정 이관 코드 입력"
        static let transferEnterMessage: String = "발급받은 코드를 입력해주세요"
        static let transferEnterButtonTitle: String = "계정 이관하기"
    }
    
    private let transferEnterMessageLabel = UILabel().then {
        $0.text = Text.transferEnterMessage
        $0.textColor = .som.gray800
        $0.typography = .som.body1WithBold
    }
    
    private lazy var textFieldBackgroundView = UIView().then {
        $0.backgroundColor = .som.gray50
        $0.layer.borderColor = UIColor.som.p300.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 12
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.touch)
        )
        $0.addGestureRecognizer(gestureRecognizer)
    }
    private lazy var textField = UITextField().then {
        let paragraphStyle = NSMutableParagraphStyle()
        $0.defaultTextAttributes[.paragraphStyle] = paragraphStyle
        $0.defaultTextAttributes[.foregroundColor] = UIColor.som.black
        $0.defaultTextAttributes[.font] = Typography.som.body1WithRegular.font
        $0.tintColor = .som.p300
        
        $0.textAlignment = .center
        
        $0.enablesReturnKeyAutomatically = true
        $0.returnKeyType = .go
        
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.spellCheckingType = .no
        
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        
        $0.delegate = self
    }
    
    private let transferMemberButton = UIButton().then {
        let typography = Typography.som.body1WithBold
        var attributes = typography.attributes
        attributes.updateValue(typography.font, forKey: .font)
        attributes.updateValue(UIColor.som.white, forKey: .foregroundColor)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init(
            Text.transferEnterButtonTitle,
            attributes: AttributeContainer(attributes)
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            AttributeContainer(attributes)
        }
        $0.configuration = config
        $0.backgroundColor = .som.p300
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    
    // MARK: Override func
    
    @objc
    private func touch(sender: UIGestureRecognizer) {
        if !self.textField.isFirstResponder {
            self.textField.becomeFirstResponder()
        }
    }
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textField.becomeFirstResponder()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        let transferBackgroundView = UIView().then {
            $0.backgroundColor = .som.gray50
            $0.layer.cornerRadius = 22
            $0.clipsToBounds = true
        }
        self.view.addSubview(transferBackgroundView)
        transferBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(149)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        transferBackgroundView.addSubview(self.transferEnterMessageLabel)
        self.transferEnterMessageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(44)
            $0.centerX.equalToSuperview()
        }
        
        transferBackgroundView.addSubview(self.textFieldBackgroundView)
        self.textFieldBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.transferEnterMessageLabel.snp.bottom).offset(46)
            $0.bottom.trailing.equalToSuperview().offset(-20)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(64)
        }
        self.textFieldBackgroundView.addSubview(self.textField)
        self.textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        self.view.addSubview(self.transferMemberButton)
        self.transferMemberButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
        }
    }
    
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
        
        let margin: CGFloat = height + 24
        self.transferMemberButton.snp.updateConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-margin)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: EnterMemberTransferViewReactor) {
        
        // Action
        let transferCode = self.textField.rx.text.orEmpty.distinctUntilChanged()
        transferCode
            .map { $0.isEmpty }
            .subscribe(with: self) { object, isEmpty in
                let updateConfigHandler: UIButton.ConfigurationUpdateHandler = { button in
                    var updateConfig = button.configuration
                    let updateTextAttributes = UIConfigurationTextAttributesTransformer { current in
                        var update = current
                        update.foregroundColor = isEmpty ? .som.gray600 : .som.white
                        return update
                    }
                    updateConfig?.titleTextAttributesTransformer = updateTextAttributes
                    button.configuration = updateConfig
                }
                
                object.transferMemberButton.configurationUpdateHandler = updateConfigHandler
                object.transferMemberButton.setNeedsUpdateConfiguration()
                
                object.transferMemberButton.isEnabled = isEmpty == false
                object.transferMemberButton.backgroundColor = isEmpty ? .som.gray300 : .som.p300
            }
            .disposed(by: self.disposeBag)
        
        self.transferMemberButton.rx.throttleTap(.seconds(3))
            .withLatestFrom(transferCode)
            .map(Reactor.Action.enterTransferCode)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isSuccess)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                object.navigationPop()
            }
            .disposed(by: self.disposeBag)
    }
}

extension EnterMemberTransferViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
