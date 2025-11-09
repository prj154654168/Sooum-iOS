//
//  ResignTextFieldView.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import UIKit

import SnapKit
import Then

class ResignTextFieldView: UIView {
    
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
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(54)
        }
        self.textFieldBackgroundView.addSubview(self.textField)
        self.textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
    }
}

extension ResignTextFieldView: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        
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
