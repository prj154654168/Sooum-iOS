//
//  OnboardingNicknameTextFieldView.swift
//  SOOUM
//
//  Created by JDeoks on 11/7/24.
//

import UIKit

import SnapKit
import Then


class OnboardingNicknameTextFieldView: UIView {
    
    
    // MARK: Views
    
    private lazy var textFieldBackgroundView = UIView().then {
        $0.backgroundColor = .som.gray50
        $0.layer.cornerRadius = 12
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.touch)
        )
        $0.addGestureRecognizer(gestureRecognizer)
    }
    
    lazy var textField = UITextField().then {
        let paragraphStyle = NSMutableParagraphStyle()
        $0.defaultTextAttributes[.paragraphStyle] = paragraphStyle
        $0.defaultTextAttributes[.foregroundColor] = UIColor.som.black
        $0.defaultTextAttributes[.font] = Typography.som.body1WithRegular.font
        $0.tintColor = .som.p300
        
        $0.enablesReturnKeyAutomatically = true
        $0.returnKeyType = .go
        
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.spellCheckingType = .no
        
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        
        $0.delegate = self
    }
    
    private let errorMessageContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 4
        
        $0.isHidden = true
    }
    
    private let errorImageView = UIImageView().then {
        $0.image = .init(.image(.errorTriangle))
        $0.tintColor = .som.red
    }
    
    private let errorMessageLabel = UILabel().then {
        $0.textColor = .som.red
        $0.typography = .som.body2WithBold
    }
    
    private let characterLabel = UILabel().then {
        $0.textColor = .som.gray500
        $0.typography = .som.body1WithRegular
    }
    
    private lazy var clearButton = SOMButton().then {
        $0.image = .init(.icon(.outlined(.cancel)))
        $0.foregroundColor = .som.black
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.clear)
        )
        $0.addGestureRecognizer(gestureRecognizer)
    }
    
    
    // MARK: Variables
    
    private let maxCharacter: Int = 8
    
    var text: String? {
        set {
            self.textField.text = newValue
        }
        get {
            return self.textField.text
        }
    }
    
    var placeholder: String? {
        set {
            if let string: String = newValue {
                self.textField.attributedPlaceholder = NSAttributedString(
                    string: string,
                    attributes: [
                        .foregroundColor: UIColor.som.gray500,
                        .font: Typography.som.body1WithRegular.font
                    ]
                )
            } else {
                self.textField.attributedPlaceholder = nil
            }
        }
        
        get {
            return self.textField.attributedPlaceholder?.string
        }
    }
    
    var errorMessage: String? {
        set {
            self.errorMessageContainer.isHidden = newValue == nil
            self.errorMessageLabel.text = newValue
        }
        get {
            return self.errorMessageLabel.text
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
        if !self.textField.isFirstResponder {
            self.textField.becomeFirstResponder()
        }
    }
    
    @objc
    private func clear() {
        self.clearButton.isHidden = true
        self.text = nil
        self.textField.sendActions(for: .editingChanged)
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.textFieldBackgroundView)
        self.textFieldBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        }
        self.textFieldBackgroundView.addSubview(self.textField)
        self.textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
        }
        
        self.textFieldBackgroundView.addSubview(self.clearButton)
        self.clearButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.textField.snp.trailing).offset(9)
            $0.trailing.equalToSuperview().offset(-8)
            $0.size.equalTo(32)
        }
        
        self.addSubview(self.errorMessageContainer)
        self.errorMessageContainer.snp.makeConstraints {
            $0.top.equalTo(self.textFieldBackgroundView.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(24)
        }
        self.errorMessageContainer.addArrangedSubview(self.errorImageView)
        self.errorImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        self.errorMessageContainer.addArrangedSubview(self.errorMessageLabel)
        
        self.addSubview(self.characterLabel)
        self.characterLabel.snp.makeConstraints {
            $0.top.equalTo(self.textFieldBackgroundView.snp.bottom).offset(12)
            $0.leading.greaterThanOrEqualTo(self.errorMessageContainer.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}

extension OnboardingNicknameTextFieldView: UITextFieldDelegate {
    
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
        
        let nsString: NSString? = textField.text as NSString?
        let newString: String = nsString?.replacingCharacters(in: range, with: string) ?? ""
        
        self.clearButton.isHidden = newString.isEmpty
        return newString.count < self.maxCharacter + 1
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        let text = textField.text ?? ""
        self.clearButton.isHidden = text.isEmpty
        self.characterLabel.text = text.count.description + "/" + self.maxCharacter.description
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
