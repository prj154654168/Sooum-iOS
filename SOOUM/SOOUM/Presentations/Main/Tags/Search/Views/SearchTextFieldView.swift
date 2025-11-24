//
//  SearchTextFieldView.swift
//  SOOUM
//
//  Created by 오현식 on 11/20/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa

class SearchTextFieldView: UIView {
    
    
    // MARK: Views
    
    private let iconView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.search))))
        $0.tintColor = .som.v2.gray400
    }
    
    private lazy var textFieldBackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.gray100
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        
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
        $0.returnKeyType = .search
        
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.spellCheckingType = .no
        
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh + 1, for: .vertical)
        
        $0.delegate = self
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
    
    let textFieldDidReturn = PublishRelay<String?>()
    
    
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
            $0.edges.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        self.textFieldBackgroundView.addSubview(self.iconView)
        self.iconView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(18)
        }
        
        self.textFieldBackgroundView.addSubview(self.textField)
        self.textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.iconView.snp.trailing).offset(10)
        }
        
        self.textFieldBackgroundView.addSubview(self.clearButton)
        self.clearButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.lessThanOrEqualTo(self.textField.snp.trailing).offset(-18)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(24)
        }
    }
}


// MARK: UITextFieldDelegate

extension SearchTextFieldView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.clearButton.isHidden = self.isTextEmpty
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        self.clearButton.isHidden = self.isTextEmpty
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.clearButton.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.textFieldDidReturn.accept(textField.text)
        return true
    }
}
