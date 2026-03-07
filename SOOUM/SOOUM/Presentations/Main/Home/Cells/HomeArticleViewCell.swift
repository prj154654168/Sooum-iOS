//
//  HomeArticleViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 1/31/26.
//

import UIKit

import SnapKit
import Then

final class HomeArticleViewCell: UITableViewCell {
    
    static let cellIdentifier = String(reflecting: HomeArticleViewCell.self)
    
    enum Text {
        static let noCommentCardMessage: String = "첫 댓글을 남겨보세요"
        static let commentCardTrailingMessage: String = "명이 카드를 남겼어요"
    }
    
    
    // MARK: Views
    
    private lazy var shadowbackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.cornerRadius = 16
    }
    
    private let dot = UIView().then {
        $0.backgroundColor = .som.v2.rMain
        $0.layer.borderColor = UIColor.som.v2.white.cgColor
        $0.layer.cornerRadius = 12 * 0.5
        $0.layer.borderWidth = 2
    }
    
    private let profileImageView = UIImageView().then {
        $0.image = .init(.image(.v2(.profile_medium)))
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    private let contentsContainer = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .equalSpacing
        $0.spacing = 0
    }
    
    private let nicknameLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption2
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = .som.v2.gray600
        $0.typography = .som.v2.subtitle3.withAlignment(.left)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    // B 유형
    private let commentedContainer = UIView()
    
    
    // MARK: Variables
    
    private(set) var model: ArticleCardInfo?
    
    
    // MARK: Constraint
    
    private var cellHeightConstraint: Constraint?
    
    
    // MARK: Initialize
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.shadowbackgroundView.setShadow(
            radius: 6,
            color: UIColor(hex: "#ABBED11A").withAlphaComponent(0.1),
            blur: 16,
            offset: .init(width: 0, height: 6)
        )
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.shadowbackgroundView)
        self.shadowbackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            self.cellHeightConstraint = $0.height.equalTo(72).constraint
        }
        
        self.shadowbackgroundView.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.size.equalTo(48)
        }
        
        self.shadowbackgroundView.addSubview(self.dot)
        self.dot.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.top)
            $0.trailing.equalTo(self.profileImageView.snp.trailing)
            $0.size.equalTo(12)
        }
        
        self.shadowbackgroundView.addSubview(self.contentsContainer)
        self.contentsContainer.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.profileImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-12)
        }
        self.contentsContainer.addArrangedSubview(self.nicknameLabel)
        self.contentsContainer.addArrangedSubview(self.contentLabel)
        self.contentsContainer.addArrangedSubview(self.commentedContainer)
    }
    
    private func setupCommentedContainer(with urlStrings: [String], count commentedCount: Int) {
        
        self.commentedContainer.subviews.forEach { $0.removeFromSuperview() }
        
        let commentedProfileContainer = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = -4
        }
        
        urlStrings.forEach { urlString in
            
            let imageView = UIImageView().then {
                $0.image = .init(.image(.v2(.profile_small)))
                $0.contentMode = .scaleAspectFill
                $0.backgroundColor = .som.v2.white
                $0.layer.cornerRadius = 20 * 0.5
                $0.layer.borderWidth = 1
                $0.layer.borderColor = UIColor.som.v2.white.cgColor
                $0.clipsToBounds = true
            }
            if urlString.isEmpty == false { imageView.setImage(strUrl: urlString) }
            
            imageView.snp.makeConstraints {
                $0.size.equalTo(20)
            }
            
            commentedProfileContainer.addArrangedSubview(imageView)
        }
        
        let hasComment = commentedCount > 0
        let countLabel = UILabel().then {
            $0.text = hasComment ?
                "\(commentedCount.description)\(Text.commentCardTrailingMessage)" :
                Text.noCommentCardMessage
            $0.textColor = .som.v2.gray500
            $0.typography = .som.v2.caption2
        }
        
        self.commentedContainer.addSubview(commentedProfileContainer)
        commentedProfileContainer.snp.makeConstraints {
            $0.verticalEdges.leading.equalToSuperview()
        }
        
        self.commentedContainer.addSubview(countLabel)
        countLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(commentedProfileContainer.snp.trailing).offset(hasComment ? 4 : 0)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        self.commentedContainer.snp.remakeConstraints {
            $0.height.equalTo(hasComment ? 20 : 18)
        }
    }
    
    
    // MARK: Public func
    
    func bind(_ model: ArticleCardInfo) {
        
        self.model = model
        
        let cellHeight: CGFloat = model.abTestType == .b ? 87 : 72
        self.cellHeightConstraint?.update(offset: cellHeight)
        
        self.dot.isHidden = model.isRead
        
        if model.profileImageUrl.isEmpty {
            self.profileImageView.image = .init(.image(.v2(.profile_medium)))
        } else {
            self.profileImageView.setImage(strUrl: model.profileImageUrl)
        }
        
        self.nicknameLabel.text = model.nickname
        self.nicknameLabel.typography = .som.v2.caption2
        
        self.contentLabel.text = model.cardContent
        self.contentLabel.typography = .som.v2.subtitle3.withAlignment(.left)
        
        let isBType = model.abTestType == .b || model.articleTypeB != nil
        self.commentedContainer.isHidden = isBType == false
        if isBType,
           let urlStrings = model.articleTypeB?.writerProfileImgUrls,
           let count = model.articleTypeB?.totalWriterCnt {
            
            self.setupCommentedContainer(with: urlStrings, count: count)
        }
    }
}
