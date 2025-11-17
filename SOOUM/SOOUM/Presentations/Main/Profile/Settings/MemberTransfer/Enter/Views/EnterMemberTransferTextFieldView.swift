//
//  EnterMemberTransferTextFieldView.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/25.
//

import UIKit

import SnapKit
import Then

class EnterMemberTransferTextFieldView: UIView {
    
    
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
    
    private let guideMessageLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    
    
    // MARK: Variables
    
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
                        .foregroundColor: UIColor.som.v2.gray500,
                        .font: Typography.som.v2.subtitle1.font
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
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        self.addSubview(self.guideMessageLabel)
        self.guideMessageLabel.snp.makeConstraints {
            $0.top.equalTo(self.textFieldBackgroundView.snp.bottom).offset(8)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
    }
}

extension EnterMemberTransferTextFieldView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
