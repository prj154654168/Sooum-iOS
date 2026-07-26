//
//  ArticlePreviewCollectionCell.swift
//  SOOUM
//
//  Created by Codex on 7/26/26.
//

import UIKit

import SnapKit
import Then

final class ArticlePreviewCollectionCell: UICollectionViewCell {
    
    private enum Metric {
        static let topInset: CGFloat = 14
        static let horizontalInset: CGFloat = 16
        static let titleBottomSpacing: CGFloat = 8
        static let bottomInset: CGFloat = 12
        static let avatarSize: CGFloat = 20
    }
    
    static let cellIdentifier = String(reflecting: ArticlePreviewCollectionCell.self)
    
    private let cardBackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.gray100
        $0.layer.cornerRadius = 8
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray600
        $0.typography = .som.v2.subtitle3.withAlignment(.left)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    private let footerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 4
    }
    
    private let commentedProfileContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = -4
    }
    
    private let countLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = nil
        self.countLabel.text = nil
        self.commentedProfileContainer.isHidden = false
        self.commentedProfileContainer.arrangedSubviews.forEach { view in
            self.commentedProfileContainer.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    func bind(_ model: ArticleCardInfo) {
        
        self.titleLabel.text = model.cardContent
        
        let hasProfiles = model.writerProfileImgUrls.isEmpty == false
        let hasComment = model.totalWriterCnt > 0
        self.countLabel.text = hasComment
            ? "\(model.totalWriterCnt.description)\(HomeArticleViewCell.Text.commentCardTrailingMessage)"
            : HomeArticleViewCell.Text.noCommentCardMessage
        
        if hasProfiles {
            model.writerProfileImgUrls.forEach { urlString in
                let imageView = UIImageView().then {
                    $0.image = .init(.image(.v2(.profile_small)))
                    $0.contentMode = .scaleAspectFill
                    $0.backgroundColor = .som.v2.white
                    $0.layer.cornerRadius = Metric.avatarSize * 0.5
                    $0.layer.borderWidth = 1
                    $0.layer.borderColor = UIColor.som.v2.white.cgColor
                    $0.clipsToBounds = true
                }
                
                if urlString.isEmpty == false {
                    imageView.setImage(strUrl: urlString)
                }
                
                imageView.snp.makeConstraints {
                    $0.size.equalTo(Metric.avatarSize)
                }
                
                self.commentedProfileContainer.addArrangedSubview(imageView)
            }
            self.commentedProfileContainer.isHidden = false
        } else {
            self.commentedProfileContainer.isHidden = true
        }
    }
    
    static func preferredHeight(for model: ArticleCardInfo, width: CGFloat) -> CGFloat {
        let contentWidth = width - (Metric.horizontalInset * 2)
        let titleHeight = model.cardContent.height(
            withConstrainedWidth: contentWidth,
            font: Typography.som.v2.subtitle3.font
        )
        let footerText = model.totalWriterCnt > 0
            ? "\(model.totalWriterCnt.description)\(HomeArticleViewCell.Text.commentCardTrailingMessage)"
            : HomeArticleViewCell.Text.noCommentCardMessage
        let footerLabelHeight = footerText.height(
            withConstrainedWidth: contentWidth,
            font: Typography.som.v2.caption2.font
        )
        let footerHeight = model.writerProfileImgUrls.isEmpty
            ? footerLabelHeight
            : max(Metric.avatarSize, footerLabelHeight)
        
        return ceil(
            Metric.topInset +
            max(titleHeight, Typography.som.v2.subtitle3.lineHeight) +
            Metric.titleBottomSpacing +
            footerHeight +
            Metric.bottomInset
        )
    }
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.cardBackgroundView)
        self.cardBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.cardBackgroundView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Metric.topInset)
            $0.leading.equalToSuperview().offset(Metric.horizontalInset)
            $0.trailing.equalToSuperview().offset(-Metric.horizontalInset)
        }
        
        self.cardBackgroundView.addSubview(self.footerStackView)
        self.footerStackView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(Metric.titleBottomSpacing)
            $0.leading.equalToSuperview().offset(Metric.horizontalInset)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Metric.horizontalInset)
            $0.bottom.equalToSuperview().offset(-Metric.bottomInset)
        }
        
        self.footerStackView.addArrangedSubview(self.commentedProfileContainer)
        self.footerStackView.addArrangedSubview(self.countLabel)
    }
}
