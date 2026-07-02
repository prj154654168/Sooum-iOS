//
//  ProfileIntroductionTextView.swift
//  SOOUM
//
//  Created by 오현식 on 7/1/26.
//

import UIKit

import SnapKit
import Then

final class ProfileIntroductionTextView: UIView {
    
    enum Constants {
        static let maxCharacters: Int = 200
    }
    
    private lazy var backgroundView = UIView().then {
        $0.backgroundColor = .som.v2.gray100
        $0.layer.cornerRadius = 10
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.focusTextView)
        )
        $0.addGestureRecognizer(gestureRecognizer)
    }
    
    private let placeholderLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.subtitle1
    }
    
    lazy var textView = UITextView().then {
        $0.backgroundColor = .clear
        $0.typography = .som.v2.subtitle1.withAlignment(.left)
        $0.textAlignment = .left
        $0.textColor = .som.v2.black
        $0.tintColor = .som.v2.black
        $0.textContainerInset = .init(top: 12, left: 20, bottom: 12, right: 20)
        $0.textContainer.lineFragmentPadding = 0
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.delegate = self
    }
    
    var placeholder: String? {
        set {
            self.placeholderLabel.text = newValue
        }
        get {
            return self.placeholderLabel.text
        }
    }
    
    var text: String? {
        set {
            self.textView.text = newValue
            self.updatePlaceholderVisibility()
        }
        get {
            return self.textView.text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
        self.updatePlaceholderVisibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func focusTextView() {
        if self.textView.isFirstResponder == false {
            self.textView.becomeFirstResponder()
        }
    }
    
    private func setupConstraints() {
        self.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.backgroundView.addSubview(self.textView)
        self.textView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.backgroundView.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
    }
    
    private func updatePlaceholderVisibility() {
        let trimmedText = self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.placeholderLabel.isHidden = trimmedText.isEmpty == false
    }
}

extension ProfileIntroductionTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.updatePlaceholderVisibility()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.updatePlaceholderVisibility()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.updatePlaceholderVisibility()
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        return textView.shouldChangeText(
            in: range,
            replacementText: text,
            maxCharacters: Constants.maxCharacters
        )
    }
}
