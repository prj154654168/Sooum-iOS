//
//  WriteCardFooter.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import UIKit

import SnapKit
import Then

class WriteCardTagFooter: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: WriteCardTagFooter.self)
    
    enum Constants {
        static let maxCharacters: Int = 15
    }
    
    
    // MARK: Views
    
    private let imageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.plus))))
        $0.tintColor = .som.v2.white
    }
    
    lazy var textField = UITextField().then {
        $0.typography = .som.v2.caption2
        $0.textColor = .som.v2.white
        $0.tintColor = .som.v2.white
        
        $0.returnKeyType = .done
        
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
        didSet {
            self.textField.text = self.placeholder
        }
    }
    
    var typography: Typography? {
        didSet {
            self.textField.typography = self.typography
        }
    }
    
    
    // MARK: Delegate
    
    weak var delegate: WriteCardTagFooterDelegate?
    
    
    // MARK: Override func
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
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
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.backgroundColor = .som.v2.dim
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.size.equalTo(14)
        }
        
        self.addSubview(self.textField)
        self.textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.imageView.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().offset(-8)
        }
    }
}


// MARK: SendActions

extension WriteCardTagFooter {
    
    func sendActionsToTextField(for controlEvents: UIControl.Event) {
        self.textField.sendActions(for: controlEvents)
    }
    
    func addTargetToTextField(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        self.textField.addTarget(target, action: action, for: controlEvents)
    }
}


// MARK: UITextFieldDelegate

extension WriteCardTagFooter: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textField.text = nil
        self.imageView.image = .init(.icon(.v2(.outlined(.hash))))
        self.imageView.tintColor = .som.v2.gray300
        self.delegate?.textFieldDidBeginEditing(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.textField.text = self.placeholder
        self.imageView.image = .init(.icon(.v2(.outlined(.plus))))
        self.imageView.tintColor = .som.v2.white
        self.delegate?.textFieldDidEndEditing(self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 타이핑 시 공백 제거
        if string == " " && range.length == 0 {
            return false
        }
        // 붙여넣기 공백 제거
        let isPasting: Bool = string.count > 1 || range.length > 0
        var newString: String = string
        if isPasting {
            newString = string.replacingOccurrences(of: " ", with: "")
            if newString.isEmpty && string.contains(" ") {
                return false
            }
        }
        
        return textField.shouldChangeCharactersIn(
            in: range,
            replacementString: newString,
            maxCharacters: Constants.maxCharacters
        )
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.delegate?.textFieldReturnKeyClicked(self) ?? true
    }
}
