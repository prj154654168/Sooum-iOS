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
        $0.tintColor = .som.gray800
    }
    private let likeCountLabel = UILabel().then {
        $0.textColor = .som.gray800
        $0.textAlignment = .center
        $0.typography = .som.body2WithRegular
    }
    
    let commentBackgroundButton = UIButton()
    private let commentImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.commentAdd)))
        $0.tintColor = .som.gray800
    }
    private let commentCountLabel = UILabel().then {
        $0.textColor = .som.gray800
        $0.textAlignment = .center
        $0.typography = .som.body2WithRegular
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
            $0.leading.equalToSuperview().offset(20)
        }
        self.addSubviews(self.likeBackgroundButton)
        self.likeBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(likeContainer)
        }
        
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
            $0.leading.equalTo(likeContainer.snp.trailing).offset(6)
        }
        self.addSubviews(self.commentBackgroundButton)
        self.commentBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(commentContainer)
        }
    }
    
    func updateLikeContainerColor(_ isSelected: Bool) {
        
        self.likeImageView.image = .init(.icon(isSelected ? .filled(.heart) : .outlined(.heart)))
        self.likeImageView.tintColor = isSelected ? .som.p300 : .som.gray800
        self.likeCountLabel.textColor = isSelected ? .som.p300 : .som.gray800
    }
}
