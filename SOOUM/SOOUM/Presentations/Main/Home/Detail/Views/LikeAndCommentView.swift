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
    
    
    // MARK: Views
    
    let likeBackgroundButton = UIButton()
    private let likeContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 4
    }
    private let likeImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.heart))))
        $0.tintColor = .som.v2.gray500
    }
    private let likeCountLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption1
    }
    
    let commentBackgroundButton = UIButton()
    private let commentContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 4
    }
    private let commentImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.message_circle))))
        $0.tintColor = .som.v2.gray500
    }
    private let commentCountLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption1
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
        
        self.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        
        let container = UIStackView(arrangedSubviews: [
            self.likeContainer,
            self.commentContainer
        ]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.spacing = 15
        }
        self.addSubview(container)
        container.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        self.likeContainer.addArrangedSubviews(self.likeImageView, self.likeCountLabel)
        self.likeImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }
        self.addSubview(self.likeBackgroundButton)
        self.likeBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(self.likeContainer)
        }
        
        self.commentContainer.addArrangedSubviews(self.commentImageView, self.commentCountLabel)
        self.commentImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }
        self.addSubview(self.commentBackgroundButton)
        self.commentBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(self.commentContainer)
        }
        
        self.addSubview(self.visitedLabel)
        self.visitedLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(container.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func updateLikeContainerColor(_ isSelected: Bool) {
        self.likeImageView.image = .init(.icon(.v2(isSelected ? .filled(.heart) : .outlined(.heart))))
        self.likeImageView.tintColor = isSelected ? .som.v2.rMain : .som.v2.gray500
    }
    
    func updateViewsWhenDeleted() {
        self.likeContainer.removeFromSuperview()
        self.commentBackgroundButton.removeFromSuperview()
        self.visitedLabel.removeFromSuperview()
    }
}
