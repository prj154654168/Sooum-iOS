//
//  WriteTagTextField.swift
//  SOOUM
//
//  Created by 오현식 on 10/19/24.
//

import UIKit

import SnapKit
import Then


class WriteTagTextField: UIView {
    
    private lazy var backgroundView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.borderColor = UIColor.som.gray200.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.touch)
        )
        $0.addGestureRecognizer(gestureRecognizer)
    }
    
    private let textContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    lazy var textField = UITextField().then {
        let paragraphStyle = NSMutableParagraphStyle()
        $0.defaultTextAttributes[.paragraphStyle] = paragraphStyle
        $0.defaultTextAttributes[.foregroundColor] = UIColor.som.gray600
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
    
    let addTagButton = SOMButton().then {
        $0.image = .init(.icon(.outlined(.plus)))
        $0.foregroundColor = .som.gray600
        
        $0.isHidden = true
        
        $0.setContentHuggingPriority(.defaultHigh + 1, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
    }
    
    weak var delegate: WriteTagTextFieldDelegate?
    
    var text: String? {
        set {
            self.textField.text = newValue
        }
        get {
            return self.textField.text
        }
    }
    
    var isTextEmpty: Bool {
        return self.text?.isEmpty ?? false
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    @objc
    private func touch(sender: UIGestureRecognizer) {
        if !self.textField.isFirstResponder {
            self.textField.becomeFirstResponder()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        self.textContainer.addArrangedSubviews(self.textField, self.addTagButton)
        self.backgroundView.addSubview(self.textContainer)
        self.textContainer.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(25)
            $0.trailing.equalToSuperview().offset(-11)
        }
        
        self.addTagButton.snp.makeConstraints {
            $0.size.equalTo(24)
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
            self.backgroundView.layer.borderColor = outlineColor.cgColor
        }
    }
}

extension WriteTagTextField {
    
    func sendActionsToTextField(for controlEvents: UIControl.Event) {
        self.textField.sendActions(for: controlEvents)
    }
}

extension WriteTagTextField: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let shouldBeginEditing = self.delegate?.textFieldShouldBeginEditing(self) ?? true
        self.animate(outlineColor: .som.p300)
        self.addTagButton.isHidden = false
        return shouldBeginEditing
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.textFieldDidBeginEditing(self)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let shouldEndEditing = self.delegate?.textFieldShouldEndEditing(self) ?? true
        self.animate(outlineColor: .som.gray200)
        self.addTagButton.isHidden = true
        return shouldEndEditing
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.textFieldDidEndEditing(self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.delegate?.textField(self, shouldChangeTextIn: range, replacementText: string) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard !(textField.text ?? "").isEmpty else { return false }
        return self.delegate?.textFieldReturnKeyClicked(self) ?? true
    }
}
