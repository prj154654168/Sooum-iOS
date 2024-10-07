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
    
    let likeBackgroundButton = UIButton()
    private let likeImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.heart)))
        $0.tintColor = .som.black
    }
    private let likeCountLabel = UILabel().then {
        $0.textColor = .som.black
        $0.textAlignment = .center
        $0.typography = .init(
            fontContainer: Pretendard(size: 14, weight: .medium),
            lineHeight: 17,
            letterSpacing: -0.04
        )
    }
    
    let commentBackgroundButton = UIButton()
    private let commentImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.commentAdd)))
        $0.tintColor = .som.black
    }
    private let commentCountLabel = UILabel().then {
        $0.textColor = .som.black
        $0.textAlignment = .center
        $0.typography = .init(
            fontContainer: Pretendard(size: 14, weight: .medium),
            lineHeight: 17,
            letterSpacing: -0.04
        )
    }
    
    private var inputLikeCount: Int = 0
    var likeCount: Int {
        set {
            self.inputLikeCount = newValue
            self.likeCountLabel.text = newValue > 99 ? "99+" : newValue.description
        }
        get { return inputLikeCount }
    }
    
    private var inputCommentCount: Int = 0
    var commentCount: Int {
        set {
            self.inputCommentCount = newValue
            self.commentCountLabel.text = newValue > 99 ? "99+" : newValue.description
        }
        get { return inputCommentCount }
    }
    
    var isLikeSelected: Bool = false {
        didSet { self.updateLikeContainerColor(self.isLikeSelected) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let commentContainer = UIStackView(
            arrangedSubviews: [
                self.commentImageView,
                self.commentCountLabel
            ]
        ).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.spacing = 4
        }
        self.addSubviews(commentContainer)
        commentContainer.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
        self.addSubviews(self.commentBackgroundButton)
        self.commentBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(commentContainer)
        }
        
        let likeContainer = UIStackView(
            arrangedSubviews: [
                self.likeImageView,
                self.likeCountLabel
            ]
        ).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.spacing = 4
        }
        self.addSubviews(likeContainer)
        likeContainer.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(commentContainer.snp.leading).offset(-6)
        }
        self.addSubviews(self.likeBackgroundButton)
        self.likeBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(likeContainer)
        }
    }
    
    func updateLikeContainerColor(_ isSelected: Bool) {
        
        self.likeImageView.image = .init(.icon(isSelected ? .filled(.heart) : .outlined(.heart)))
        self.likeImageView.tintColor = isSelected ? .som.primary : .som.black
        self.likeCountLabel.textColor = isSelected ? .som.primary : .som.black
    }
}
