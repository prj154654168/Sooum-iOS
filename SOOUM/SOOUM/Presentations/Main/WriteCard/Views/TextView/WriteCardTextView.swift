//
//  WriteCardTextView.swift
//  SOOUM
//
//  Created by 오현식 on 10/18/24.
//

import UIKit

import SnapKit
import Then


class WriteCardTextView: UIView {
    
    private lazy var backgroundImageView = UIImageView().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var backgroundDimView = UIView().then {
        $0.backgroundColor = .som.black.withAlphaComponent(0.5)
        
        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.touch)
        )
        $0.addGestureRecognizer(gestureRecognizer)
    }
    
    lazy var textView = UITextView().then {
        $0.keyboardAppearance = .light
        $0.backgroundColor = .clear
        
        let paragraphStyle = NSMutableParagraphStyle()
        $0.typingAttributes[.paragraphStyle] = paragraphStyle
        $0.typingAttributes[.foregroundColor] = UIColor.som.white
        $0.typingAttributes[.font] = Typography.som.body1WithBold.font
        $0.tintColor = .som.p300
        
        $0.textAlignment = .center
        
        let verticalInset = (self.width * 0.9 - 40 * 2) * 0.5
        let horizontalInset = (self.width - 40 * 2) * 0.5
        $0.textContainerInset = .init(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
        $0.textContainer.lineFragmentPadding = 0
        
        $0.scrollIndicatorInsets = .init(top: 4, left: 0, bottom: 4, right: 0)
        $0.indicatorStyle = .white
        $0.isScrollEnabled = true
        
        $0.enablesReturnKeyAutomatically = true
        $0.returnKeyType = .go
        
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.spellCheckingType = .no
        
        $0.delegate = self
    }
    
    private let placeholderLabel = UILabel().then {
        $0.textColor = .som.white
        $0.typography = .som.body1WithBold
    }
    
    private let characterLabel = UILabel().then {
        $0.textColor = .init(hex: "#D6D6D6")
        // 고정된 타이포그래피가 없음
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 14, weight: .semibold),
            lineHeight: 17,
            letterSpacing: -0.04
        )
    }
    
    weak var delegate: WriteCardTextViewDelegate?
    
    var image: UIImage? {
        didSet {
            self.backgroundImageView.image = self.image
        }
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
        }
        get {
            return self.textView.text
        }
    }
    
    // TODO: 임시로 typography가 변경되면 텍스트 대치
    var typography: Typography = .som.body1WithBold {
        didSet {
            self.textView.typography = self.typography
            self.textView.text = self.text
            self.textView.textColor = .som.white
        }
    }
    
    var maxCharacter: Int? {
        didSet {
            self.characterLabel.isHidden = (maxCharacter == nil)
            
            guard let max = self.maxCharacter else { return }
            self.characterLabel.text = "0/" + max.description + "자"
        }
    }
    
    override var isFirstResponder: Bool {
        return self.textView.isFirstResponder
    }
    
    override var canBecomeFirstResponder: Bool {
        return self.textView.canBecomeFirstResponder
    }
    
    override var canResignFirstResponder: Bool {
        return self.textView.canResignFirstResponder
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return self.textView.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return self.textView.resignFirstResponder()
    }
    
    let width: CGFloat = UIScreen.main.bounds.width - 20 * 2
    
    @objc
    private func touch(_ recognizer: UITapGestureRecognizer) {
        if !self.textView.isFirstResponder {
            self.textView.becomeFirstResponder()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    private func setupConstraints() {
        
        self.layer.cornerRadius = 40
        self.clipsToBounds = true
        
        self.addSubview(self.backgroundImageView)
        self.backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            /// 가로 : 세로 = 10 : 9
            $0.width.equalTo(self.width)
            $0.height.equalTo(self.width).multipliedBy(0.9)
        }
        
        self.addSubview(self.backgroundDimView)
        self.backgroundDimView.snp.makeConstraints {
            $0.edges.equalTo(self.backgroundImageView)
        }
        
        self.addSubview(self.textView)
        self.textView.snp.makeConstraints {
            $0.center.equalToSuperview()
            let width: CGFloat = self.width - 40 * 2
            let height: CGFloat = self.width * 0.9 - 40 * 2
            $0.width.equalTo(width)
            $0.height.equalTo(height)
        }
        
        self.textView.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.addSubview(self.characterLabel)
        self.characterLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-12)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func updateTextContainerInset(_ textView: UITextView) {
        
        let min: UIEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        
        let attributedText = NSAttributedString(
            string: textView.text,
            attributes: [.font: self.typography.font]
        )
        
        let size: CGSize = .init(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        let textSize: CGSize = textView.sizeThatFits(size)
        let boundingRect = attributedText.boundingRect(
            with: textSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        let verticalInset = max(min.top, (textView.bounds.height - boundingRect.height) * 0.5)
        let horizontalInset = max(min.left, (textView.bounds.width - boundingRect.width) * 0.5)
        
        textView.textContainerInset = .init(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

extension WriteCardTextView: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        let shouldBeginEditing = self.delegate?.textViewShouldBeginEditing(self) ?? true
        
        guard let max = self.maxCharacter else { return shouldBeginEditing }
        let characterText = textView.text.count.description + "/" + max.description + "자"
        let attributedString = NSMutableAttributedString(string: characterText).then {
            let textColor = UIColor.som.white
            let range = (characterText as NSString).range(of: textView.text.count.description)
            $0.addAttribute(.foregroundColor, value: textColor, range: range)
        }
        self.characterLabel.attributedText = attributedString
        
        return shouldBeginEditing
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.textViewDidBeginEditing(self)
        
        self.placeholderLabel.isHidden = true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        let shouldEndEditing = self.delegate?.textViewShouldEndEditing(self) ?? true
        return shouldEndEditing
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.textViewDidEndEditing(self)
        
        let isHidden = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        placeholderLabel.isHidden = isHidden
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.textViewDidChange(self)
        
        self.updateTextContainerInset(textView)
        
        guard let max = self.maxCharacter else { return }
        let characterText = textView.text.count.description + "/" + max.description + "자"
        let attributedString = NSMutableAttributedString(string: characterText).then {
            let textColor = UIColor.som.white
            let range = (characterText as NSString).range(of: textView.text.count.description)
            $0.addAttribute(.foregroundColor, value: textColor, range: range)
        }
        self.characterLabel.attributedText = attributedString
    }
    
    // return key did tap
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" { self.delegate?.textViewReturnKeyClicked(self) }
        
        let currentText: String = textView.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        let newText: String = currentText.replacingCharacters(in: textRange, with: text)
        
        let shouldChangeText: Bool = (self.delegate?.textView(self, shouldChangeTextIn: range, replacementText: text) ?? true)
        
        return (newText.count <= (self.maxCharacter ?? Int.max)) && shouldChangeText
    }
}
