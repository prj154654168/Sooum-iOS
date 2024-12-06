//
//  UpdateProfileView.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then


class UpdateProfileView: UIView {
    
    enum Text {
        static let textFieldTitle: String = "닉네임"
        static let errorMessage: String = "한글자 이상 입력해주세요"
    }
    
    private let profileImageView = UIImageView().then {
        $0.image = .init(.image(.sooumLogo))
        $0.layer.cornerRadius = 128 * 0.5
        $0.clipsToBounds = true
    }
    
    let changeProfileButton = UIButton()
    private let cameraBackgroundView = UIView().then {
        $0.backgroundColor = UIColor(hex: "#B4B4B4")
        $0.layer.cornerRadius = 32 * 0.5
        $0.clipsToBounds = true
    }
    private let cameraImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.camera)))
        $0.tintColor = .som.white
    }
    
    private let textFieldTitleLabel = UILabel().then {
        $0.text = Text.textFieldTitle
        $0.textColor = .som.gray700
        $0.typography = .som.body1WithBold
    }
    
    private lazy var textFieldBackgroundView = UIView().then {
        $0.backgroundColor = .som.gray50
        $0.layer.borderColor = UIColor.som.gray50.cgColor
        $0.layer.borderWidth = 1
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
        $0.defaultTextAttributes[.foregroundColor] = UIColor.som.gray500
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
    }
    
    private let errorImageView = UIImageView().then {
        $0.image = .init(.image(.error))
    }
    
    private let errorMessageLabel = UILabel().then {
        $0.text = Text.errorMessage
        $0.textColor = .som.red
        $0.typography = .som.body2WithBold
    }
    
    private let characterLabel = UILabel().then {
        $0.text = "0/8"
        $0.textColor = .som.gray500
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 14, weight: .medium),
            lineHeight: 14,
            letterSpacing: 0.04
        )
    }
    
    private let maxCharacter: Int = 8
    
    var image: UIImage? {
        didSet {
            self.profileImageView.image = self.image
        }
    }
    
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
    
    @objc
    private func touch(sender: UIGestureRecognizer) {
        if !self.textField.isFirstResponder {
            self.textField.becomeFirstResponder()
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(42)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(128)
        }
        
        self.addSubview(self.cameraBackgroundView)
        self.cameraBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.top).offset(100)
            $0.leading.equalTo(self.profileImageView.snp.leading).offset(95)
            $0.size.equalTo(32)
        }
        self.cameraBackgroundView.addSubview(self.cameraImageView)
        self.cameraImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        self.cameraBackgroundView.addSubview(self.changeProfileButton)
        self.changeProfileButton.snp.makeConstraints {
            $0.edges.equalTo(self.cameraBackgroundView)
        }
        
        self.addSubview(self.textFieldTitleLabel)
        self.textFieldTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        
        self.addSubview(self.textFieldBackgroundView)
        self.textFieldBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.textFieldTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
        }
        self.textFieldBackgroundView.addSubview(self.textField)
        self.textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        self.addSubviews(self.errorMessageContainer)
        self.errorMessageContainer.snp.makeConstraints {
            $0.top.equalTo(self.textFieldBackgroundView.snp.bottom).offset(4)
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
            $0.top.equalTo(self.textFieldBackgroundView.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(self.errorMessageContainer.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    private func animate(outlineColor: UIColor) {
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [
                .allowUserInteraction,
                .beginFromCurrentState,
                .curveEaseOut
            ]
        ) {
            self.textFieldBackgroundView.layer.borderColor = outlineColor.cgColor
        }
    }
}

extension UpdateProfileView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.animate(outlineColor: .som.p300)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.animate(outlineColor: .som.gray50)
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        
        guard let text = textField.text else {
            return true
        }
        
        let nsString: NSString? = text as NSString?
        let newString: String = nsString?.replacingCharacters(in: range, with: string) ?? ""
        
        let characterText = newString.count.description + "/" + self.maxCharacter.description
        self.characterLabel.text = characterText
        return newString.count < self.maxCharacter
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
