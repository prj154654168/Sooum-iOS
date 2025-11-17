//
//  SOMNicknameTextField.swift
//  SOOUM
//
//  Created by 오현식 on 11/8/25.
//

import UIKit

import SnapKit
import Then

class SOMNicknameTextField: UIView {
    
    enum Constants {
        static let maxCharacters: Int = 8
    }
    
    
    // MARK: Views
    
    private lazy var textFieldBackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.gray100
        $0.layer.cornerRadius = 10
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.touch)
        )
        $0.addGestureRecognizer(gestureRecognizer)
    }
    
    lazy var textField = UITextField().then {
        let paragraphStyle = NSMutableParagraphStyle()
        $0.defaultTextAttributes[.paragraphStyle] = paragraphStyle
        $0.defaultTextAttributes[.foregroundColor] = UIColor.som.v2.black
        $0.defaultTextAttributes[.font] = Typography.som.v2.subtitle1.font
        $0.tintColor = UIColor.som.v2.black
        
        $0.enablesReturnKeyAutomatically = true
        $0.returnKeyType = .go
        
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.spellCheckingType = .no
        
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        
        $0.delegate = self
    }
    
    private let guideMessageContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 6
    }
    
    private let errorImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.error))))
        $0.tintColor = .som.v2.rMain
        $0.isHidden = true
    }
    
    private let guideMessageLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    
    private lazy var clearButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.delete_full))))
        $0.foregroundColor = .som.v2.gray500
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.clear)
        )
        $0.addGestureRecognizer(gestureRecognizer)
    }
    
    
    // MARK: Variables
    
    var text: String? {
        set {
            self.textField.text = newValue
            self.textField.sendActions(for: .valueChanged)
        }
        get {
            return self.textField.text
        }
    }
    
    var guideMessage: String? {
        set {
            self.guideMessageLabel.text = newValue
        }
        get {
            return self.guideMessageLabel.text
        }
    }
    
    var hasError: Bool {
        set {
            self.errorImageView.isHidden = newValue == false
            self.guideMessageLabel.textColor = newValue == false ? .som.v2.gray500 : .som.v2.rMain
        }
        get {
            self.errorImageView.isHidden == false
        }
    }
    
    var isTextEmpty: Bool {
        return self.text?.isEmpty ?? false
    }
    
    
    // MARK: Initalization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override var isFirstResponder: Bool {
        return self.textField.isFirstResponder
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return self.textField.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return self.textField.resignFirstResponder()
    }
    
    
    // MARK: Objc func
    
    @objc
    private func touch(sender: UIGestureRecognizer) {
        if self.textField.isFirstResponder == false {
            self.textField.becomeFirstResponder()
        }
    }
    
    @objc
    private func clear() {
        self.clearButton.isHidden = true
        self.text = nil
        self.textField.sendActions(for: .valueChanged)
        if self.textField.isFirstResponder == false {
            self.textField.becomeFirstResponder()
        }
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.textFieldBackgroundView)
        self.textFieldBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(54)
        }
        self.textFieldBackgroundView.addSubview(self.textField)
        self.textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        
        self.textFieldBackgroundView.addSubview(self.clearButton)
        self.clearButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.textField.snp.trailing).offset(14)
            $0.trailing.equalToSuperview().offset(-24)
            $0.size.equalTo(24)
        }
        
        self.addSubview(self.guideMessageContainer)
        self.guideMessageContainer.snp.makeConstraints {
            $0.top.equalTo(self.textFieldBackgroundView.snp.bottom).offset(8)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
            $0.height.equalTo(18)
        }
        self.guideMessageContainer.addArrangedSubview(self.errorImageView)
        self.errorImageView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        self.guideMessageContainer.addArrangedSubview(self.guideMessageLabel)
    }
}

extension SOMNicknameTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.clearButton.isHidden = self.isTextEmpty
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.clearButton.isHidden = true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        
        self.clearButton.isHidden = self.isTextEmpty
        
        return textField.shouldChangeCharactersIn(
            in: range,
            replacementString: string,
            maxCharacters: Constants.maxCharacters
        )
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
