//
//  LikeAndCommentView.swift
//  SOOUM
//
//  Created by 오현식 on 10/2/24.
//

import UIKit

import SnapKit
import Then

class LikeAndCommentView: UIView {
    
    enum Text {
        static let visitedPrefix: String = "조회 "
    }
    
    private enum Constants {
        static let likeCountAnimationContainerTag: Int = 9_101
        static let likeCountAnimationDuration: TimeInterval = 0.5
        static let likeCountHorizontalPadding: CGFloat = 2
    }
    
    
    // MARK: Views
    
    let likeBackgroundButton = UIButton()
    private let likeContainer = UIView()
    private let likeImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.heart))))
        $0.tintColor = .som.v2.gray500
    }
    private let likeCountContainer = UIView()
    private let likeCountLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption1.withAlignment(.left)
    }
    
    let commentBackgroundButton = UIButton()
    private let commentContainer = UIView()
    private let commentImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.message_circle))))
        $0.tintColor = .som.v2.gray500
    }
    private let commentCountLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption1.withAlignment(.left)
    }
    
    private let visitedLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption1
    }
    
    
    // MARK: Variables
    
    var likeCount: Int = 0 {
        didSet {
            self.likeCountLabel.text = self.likeCount.description
            self.likeCountLabel.typography = .som.v2.caption1
            self.updateLikeCountWidth(for: self.likeCount.description)
        }
    }
    
    var commentCount: Int = 0 {
        didSet {
            self.commentCountLabel.text = self.commentCount.description
            self.commentCountLabel.typography = .som.v2.caption1
        }
    }
    
    var visitedCount: String = "0" {
        didSet {
            self.visitedLabel.text = Text.visitedPrefix + self.visitedCount
            self.visitedLabel.typography = .som.v2.caption1
        }
    }
    
    var isLikeSelected: Bool = false {
        didSet { self.updateLikeContainerColor(self.isLikeSelected) }
    }
    
    private var likeCountWidthConstraint: Constraint?
    
    
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
        
        self.backgroundColor = .som.v2.white
        
        self.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        
        self.addSubview(self.likeContainer)
        self.likeContainer.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(60)
        }
        self.likeContainer.addSubview(self.likeImageView)
        self.likeImageView.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.size.equalTo(20)
        }
        self.likeContainer.addSubview(self.likeCountContainer)
        self.likeCountContainer.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.likeImageView.snp.trailing).offset(4)
            self.likeCountWidthConstraint = $0.width.equalTo(0).constraint
        }
        self.likeCountContainer.addSubview(self.likeCountLabel)
        self.likeCountLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.addSubview(self.likeBackgroundButton)
        self.likeBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(self.likeImageView)
        }
        
        self.addSubview(self.commentContainer)
        self.commentContainer.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalTo(self.likeContainer.snp.trailing)
            $0.width.equalTo(60)
        }
        self.commentContainer.addSubview(self.commentImageView)
        self.commentImageView.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.size.equalTo(20)
        }
        self.commentContainer.addSubview(self.commentCountLabel)
        self.commentCountLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.commentImageView.snp.trailing).offset(4)
        }
        
        self.addSubview(self.commentBackgroundButton)
        self.commentBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(self.commentImageView)
        }
        
        self.addSubview(self.visitedLabel)
        self.visitedLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(self.commentContainer.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func updateLikeContainerColor(_ isSelected: Bool) {
        self.likeImageView.image = .init(.icon(.v2(isSelected ? .filled(.heart) : .outlined(.heart))))
        self.likeImageView.tintColor = isSelected ? .som.v2.rMain : .som.v2.gray500
    }
    
    func animateLikeUpdate(
        from previousLikeCount: Int,
        to currentLikeCount: Int,
        isSelected: Bool
    ) {
        self.animateLikeTap(isSelected: isSelected)
        self.animateLikeCount(from: previousLikeCount, to: currentLikeCount)
    }
    
    func animateLikeCount(from previousLikeCount: Int, to currentLikeCount: Int) {
        let previousText = previousLikeCount.description
        let newText = currentLikeCount.description
        
        guard previousText != newText else {
            self.likeCount = currentLikeCount
            return
        }
        
        self.resetLikeCountAnimationState()
        let fixedWidth = max(
            self.likeCountWidth(for: previousText),
            self.likeCountWidth(for: newText)
        )
        self.likeCountWidthConstraint?.update(offset: fixedWidth)
        self.layoutIfNeeded()
        self.likeCountContainer.layoutIfNeeded()
        
        let containerFrame = self.likeCountContainer.convert(self.likeCountContainer.bounds, to: self)
        guard containerFrame.isEmpty == false else {
            self.likeCount = currentLikeCount
            return
        }
        
        let animationContainer = UIView(frame: containerFrame)
        animationContainer.tag = Constants.likeCountAnimationContainerTag
        animationContainer.clipsToBounds = true
        self.addSubview(animationContainer)
        
        let labelHeight = max(containerFrame.height, self.likeCountLabel.font.lineHeight)
        let animationLabel = self.makeLikeCountLabel(text: previousText)
        animationLabel.frame = animationContainer.bounds
        
        animationContainer.addSubview(animationLabel)
        self.likeCount = currentLikeCount
        self.likeCountLabel.alpha = 0
        
        UIView.animateKeyframes(
            withDuration: Constants.likeCountAnimationDuration,
            delay: 0,
            options: [.calculationModeCubic, .beginFromCurrentState],
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.48) {
                    animationLabel.transform = CGAffineTransform(
                        translationX: 0,
                        y: currentLikeCount > previousLikeCount ? -labelHeight : labelHeight
                    )
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.48, relativeDuration: 0) {
                    animationLabel.text = newText
                    animationLabel.typography = self.likeCountLabel.typography
                    animationLabel.transform = CGAffineTransform(
                        translationX: 0,
                        y: currentLikeCount > previousLikeCount ? labelHeight : -labelHeight
                    )
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.48, relativeDuration: 0.52) {
                    animationLabel.transform = .identity
                }
            },
            completion: { _ in
                self.likeCount = currentLikeCount
                self.likeCountLabel.alpha = 1
                self.updateLikeCountWidth(for: newText)
                animationContainer.removeFromSuperview()
            }
        )
    }
    
    func prepareForReuse() {
        self.resetLikeCountAnimationState()
    }
    
    func updateViewsWhenDeleted() {
        self.likeContainer.removeFromSuperview()
        self.likeBackgroundButton.removeFromSuperview()
        self.commentContainer.removeFromSuperview()
        self.commentBackgroundButton.removeFromSuperview()
        self.visitedLabel.removeFromSuperview()
    }
    
    private func animateLikeTap(isSelected: Bool) {
        self.updateLikeContainerColor(isSelected)
        
        UIView.animate(
            withDuration: 0.12,
            delay: 0,
            options: [.curveEaseOut, .beginFromCurrentState],
            animations: { [weak self] in
                self?.likeImageView.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.32,
                    delay: 0,
                    usingSpringWithDamping: 0.45,
                    initialSpringVelocity: 3,
                    options: [.curveEaseInOut, .beginFromCurrentState],
                    animations: { [weak self] in
                        self?.likeImageView.transform = .identity
                    }
                )
            }
        )
    }
    
    private func makeLikeCountLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = self.likeCountLabel.textColor
        label.textAlignment = self.likeCountLabel.textAlignment
        label.text = text
        label.typography = self.likeCountLabel.typography
        return label
    }
    
    private func resetLikeCountAnimationState() {
        self.likeCountLabel.layer.removeAllAnimations()
        self.likeCountLabel.transform = .identity
        self.likeCountLabel.alpha = 1
        self.viewWithTag(Constants.likeCountAnimationContainerTag)?.removeFromSuperview()
    }
    
    private func updateLikeCountWidth(for text: String) {
        self.likeCountWidthConstraint?.update(offset: self.likeCountWidth(for: text))
        self.layoutIfNeeded()
    }
    
    private func likeCountWidth(for text: String) -> CGFloat {
        let typography = self.likeCountLabel.typography ?? .som.v2.caption1
        var attributes = typography.attributes
        attributes.updateValue(typography.font, forKey: .font)
        let width = NSAttributedString(string: text, attributes: attributes)
            .boundingRect(
                with: CGSize(width: .greatestFiniteMagnitude, height: typography.lineHeight),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
            .width
        
        return ceil(width) + Constants.likeCountHorizontalPadding
    }
}
