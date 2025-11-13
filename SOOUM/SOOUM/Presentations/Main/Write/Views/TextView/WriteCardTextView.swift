//
//  WriteCardTextView.swift
//  SOOUM
//
//  Created by 오현식 on 10/18/24.
//

import UIKit

import SnapKit
import Then

import RxCocoa

class WriteCardTextView: UIView {
    
    enum Constants {
        static let maxCharacters: Int = 500
    }
    
    
    // MARK: Views
    
    private lazy var backgroundImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.layer.borderColor = UIColor.som.v2.white.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    private lazy var backgroundDimView = UIView().then {
        $0.backgroundColor = .som.v2.dim
        $0.layer.cornerRadius = 12
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.touch)
        )
        $0.addGestureRecognizer(gestureRecognizer)
    }
    
    lazy var textView = UITextView().then {
        $0.backgroundColor = .clear
        
        $0.typography = .som.v2.body1
        $0.textColor = .som.v2.white
        $0.tintColor = .som.v2.white
        
        $0.textContainerInset = .init(top: 20, left: 24, bottom: 20, right: 24)
        $0.textContainer.lineFragmentPadding = 0
        
        $0.scrollIndicatorInsets = .init(top: 20, left: 0, bottom: 20, right: 0)
        $0.indicatorStyle = .white
        $0.isScrollEnabled = false
        
        $0.returnKeyType = .default
        
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.spellCheckingType = .no
        
        $0.delegate = self
    }
    
    private let placeholderLabel = UILabel().then {
        $0.textColor = .som.v2.white
        $0.typography = .som.v2.body1
    }
    
    
    // MARK: Variables
    
    var imageInfo: ImageUrlInfo? {
        didSet {
            guard let imageInfo = self.imageInfo else { return }
            self.backgroundImageView.setImage(strUrl: imageInfo.imgUrl, with: imageInfo.imgName)
        }
    }
    
    var image: UIImage? {
        didSet {
            guard  let image = self.image else { return }
            self.backgroundImageView.image = image
        }
    }
    
    var placeholder: String? {
        set {
            self.placeholderLabel.text = newValue
            self.placeholderLabel.typography = self.typography
        }
        get {
            return self.placeholderLabel.text
        }
    }
    
    var text: String? {
        set {
            self.textView.text = newValue
            self.textView.typography = self.typography
        }
        get {
            return self.textView.text
        }
    }
    
    var typography: Typography = .som.v2.body1 {
        didSet {
            self.placeholder = self.placeholderLabel.text
            self.text = self.textView.text
        }
    }
    
    
    // MARK: Delegate
    
    weak var delegate: WritrCardTextViewDelegate?
    
    
    // MARK: Constraint
    
    private var textViewBackgroundHeightConstraint: Constraint?
    
    
    // MARK: Override func
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    
    // MARK: Objc func
    
    @objc
    private func touch(_ recognizer: UITapGestureRecognizer) {
        if self.textView.isFirstResponder == false {
            self.textView.becomeFirstResponder()
        }
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
        
        self.addSubview(self.backgroundImageView)
        self.backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.addSubview(self.backgroundDimView)
        self.backgroundDimView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            self.textViewBackgroundHeightConstraint = $0.height.equalTo(self.typography.lineHeight + 20 * 2).constraint
        }
        
        self.backgroundDimView.addSubview(self.textView)
        self.textView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.textView.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func updateTextContainerInsetAndHeight(_ textView: UITextView) {
        
        var attributes = self.typography.attributes
        attributes[.font] = self.typography.font
        let attributedText = NSAttributedString(
            string: textView.text,
            attributes: attributes
        )
        
        /// width 계산 시 textContainerInset 고려
        let textSize: CGSize = .init(width: textView.bounds.width - 24 * 2, height: .greatestFiniteMagnitude)
        var boundingHeight = attributedText.boundingRect(
            with: textSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).height
        /// 자연스러운 줄바꿈을 위해 offset 추가
        boundingHeight += 1.0
        
        let lines: CGFloat = boundingHeight / self.typography.lineHeight
        let isScrollEnabled: Bool = lines > 8
        let newHeight: CGFloat = isScrollEnabled ? self.typography.lineHeight * 8 : boundingHeight
        let updatedHeight: CGFloat = max(newHeight, self.typography.lineHeight)
        self.textViewBackgroundHeightConstraint?.update(offset: updatedHeight + 20 * 2)
        textView.isScrollEnabled = isScrollEnabled
    }
}

extension WriteCardTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.placeholderLabel.isHidden = true
        self.delegate?.textViewDidBeginEditing(self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let trimmedText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.isEmpty {
            textView.text = nil
            self.textViewDidChange(textView)
        }
        self.placeholderLabel.isHidden = trimmedText.isEmpty == false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.updateTextContainerInsetAndHeight(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // TODO: Return key 탭했을 때 동작
        // if text == "\n" { }
        
        return textView.shouldChangeText(
            in: range,
            replacementText: text,
            maxCharacters: Constants.maxCharacters
        )
    }
}
