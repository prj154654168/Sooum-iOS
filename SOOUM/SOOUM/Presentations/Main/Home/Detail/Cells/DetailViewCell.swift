//
//  DetailViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 10/3/24.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift

class DetailViewCell: UICollectionViewCell {
    
    enum Text {
        static let deletedCardInDetailText: String = "삭제된 카드예요"
    }
    
    private enum Layout {
        static let cardHorizontalInset: CGFloat = 32
        static let textContainerVerticalInset: CGFloat = 20
        static let textHorizontalInset: CGFloat = 24
        static let minimumTextHeight: CGFloat = Typography.som.v2.body1.lineHeight
        static let likeAndCommentHeight: CGFloat = 44
    }
    
    
    // MARK: Views
    
    let memberInfoView = MemberInfoView()
    
    /// 상세보기, 전글 배경
    private let prevCardBackgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.isHidden = true
    }
    /// 상세보기, 전글 dim
    private let prevCardBackgroundDimView = UIView().then {
        $0.backgroundColor = .som.v2.black.withAlphaComponent(0.3)
    }
    /// 상세보기, 전글 아이콘
    private let prevCardbuttonImageView = UIImageView().then {
        $0.image = .init(.image(.v2(.prev_card_button)))
        $0.tintColor = .som.v2.white
    }
    let prevCardBackgroundButton = UIButton().then {
        $0.isHidden = true
    }
    
    /// 상세보기, 배경 이미지
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.borderColor = UIColor.som.v2.gray100.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 16
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.isUserInteractionEnabled = true
    }
    /// 상세보기, 본문 dim
    private let contentBackgroundDimView = UIView().then {
        $0.backgroundColor = .som.v2.dim
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    /// 상세보기, 본문
    private let contentScrollView = UIScrollView().then {
        $0.isScrollEnabled = false
        $0.alwaysBounceVertical = true
        $0.delaysContentTouches = false
        $0.canCancelContentTouches = true
        $0.showsVerticalScrollIndicator = true
        $0.showsHorizontalScrollIndicator = false
        $0.indicatorStyle = .white
        $0.scrollIndicatorInsets = .zero
    }
    private let contentLabelView = UILabel().then {
        $0.textColor = .som.v2.white
        $0.typography = .som.v2.body1
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    /// 상세보기, 카드 삭제 됐을 때 배경
    private let deletedCardInDetailBackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.gray100
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
        $0.isHidden = true
    }
    /// 상세보기, 카드 삭제 됐을 때 이미지
    private let deletedCardInDetailImageView = UIImageView().then {
        $0.image = .init(.image(.v2(.detail_delete_card)))
    }
    /// 상세보기, 카드 삭제 됐을 때 라벨
    private let deletedCardInDetailLabel = UILabel().then {
        $0.text = Text.deletedCardInDetailText
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.body1
    }
    
    let tags = WrittenTags()
    
    let likeAndCommentView = LikeAndCommentView()
    
    
    // MARK: Variables
    
    private(set) var model: DetailCardInfo?
    
    var disposeBag = DisposeBag()
    
    
    // MARK: Constraint
    
    private var textViewBackgroundHeightConstraint: Constraint?
    private var likeAndCommentHeightConstraint: Constraint?
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override func
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
        self.likeAndCommentView.prepareForReuse()
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.backgroundColor = .som.v2.white
        
        self.contentView.addSubview(self.memberInfoView)
        self.memberInfoView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        self.contentView.addSubview(self.backgroundImageView)
        self.backgroundImageView.snp.makeConstraints {
            $0.top.equalTo(self.memberInfoView.snp.bottom)
            $0.centerX.equalToSuperview()
            let size: CGFloat = UIScreen.main.bounds.width - 16 * 2
            $0.size.equalTo(size)
        }
        
        self.backgroundImageView.addSubview(self.prevCardBackgroundImageView)
        self.prevCardBackgroundImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.size.equalTo(40)
        }
        self.prevCardBackgroundImageView.addSubview(self.prevCardBackgroundDimView)
        self.prevCardBackgroundDimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.prevCardBackgroundDimView.addSubview(self.prevCardbuttonImageView)
        self.prevCardbuttonImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        self.backgroundImageView.addSubview(self.prevCardBackgroundButton)
        self.prevCardBackgroundButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.size.equalTo(40)
        }
        
        self.backgroundImageView.addSubview(self.contentBackgroundDimView)
        self.contentBackgroundDimView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            self.textViewBackgroundHeightConstraint = $0.height.equalTo(Typography.som.v2.body1.lineHeight + 20 * 2).constraint
        }
        
        self.contentBackgroundDimView.addSubview(self.contentScrollView)
        self.contentScrollView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        self.contentScrollView.addSubview(self.contentLabelView)
        self.contentLabelView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(self.contentScrollView.snp.width)
        }
        
        self.contentView.addSubview(self.tags)
        self.tags.snp.makeConstraints {
            $0.bottom.equalTo(self.backgroundImageView.snp.bottom).offset(-16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(28)
        }
        
        self.contentView.addSubview(self.likeAndCommentView)
        self.likeAndCommentView.snp.makeConstraints {
            $0.top.equalTo(self.backgroundImageView.snp.bottom)
            $0.bottom.horizontalEdges.equalToSuperview()
            self.likeAndCommentHeightConstraint = $0.height.equalTo(Layout.likeAndCommentHeight).constraint
        }
        
        self.contentView.addSubview(self.deletedCardInDetailBackgroundView)
        self.deletedCardInDetailBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.memberInfoView.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.trailing.equalToSuperview().offset(-16)
        }
        self.deletedCardInDetailBackgroundView.addSubview(self.deletedCardInDetailImageView)
        self.deletedCardInDetailImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-20)
            $0.centerX.equalToSuperview()
        }
        self.deletedCardInDetailBackgroundView.addSubview(self.deletedCardInDetailLabel)
        self.deletedCardInDetailLabel.snp.makeConstraints {
            $0.top.equalTo(self.deletedCardInDetailImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func updateTextContainerInsetAndHeight(_ content: String, typography: Typography) {
        let contentWidth = max(
            UIScreen.main.bounds.width - Layout.cardHorizontalInset * 2 - Layout.textHorizontalInset * 2,
            0
        )
        let textHeight = Self.textHeight(for: content, typography: typography, width: contentWidth)
        let maxVisibleTextHeight = typography.lineHeight * 8
        let visibleTextHeight = min(textHeight, maxVisibleTextHeight)
        
        self.textViewBackgroundHeightConstraint?.update(
            offset: visibleTextHeight + Layout.textContainerVerticalInset * 2
        )
        self.contentScrollView.isScrollEnabled = textHeight > maxVisibleTextHeight
        self.contentScrollView.showsVerticalScrollIndicator = textHeight > maxVisibleTextHeight
        self.contentScrollView.setContentOffset(.zero, animated: false)
    }
    
    
    // MARK: Public func
    
    func setModels(_ model: DetailCardInfo, showsLikeAndCommentView: Bool) {
        
        self.model = model
        
        self.memberInfoView.member = (model.nickname, model.profileImgURL)
        self.memberInfoView.distance = model.distance
        self.memberInfoView.createAt = model.createdAt
        
        if let prevCardInfo = model.prevCardInfo {
            
            self.prevCardBackgroundImageView.setImage(strUrl: prevCardInfo.prevCardImgURL)
            
            self.prevCardBackgroundImageView.isHidden = false
            self.prevCardBackgroundButton.isHidden = false
        } else {
            
            self.prevCardBackgroundImageView.isHidden = true
            self.prevCardBackgroundButton.isHidden = true
        }
        
        if let isPrevCardDeleted = model.prevCardInfo?.isPrevCardDeleted, isPrevCardDeleted {
            
            self.prevCardBackgroundImageView.image = nil
        }
        
        self.backgroundImageView.setImage(strUrl: model.cardImgURL, with: model.cardImgName)
        
        let typography = Self.typography(for: model.font)
        self.contentLabelView.text = model.cardContent
        self.contentLabelView.typography = typography
        self.updateTextContainerInsetAndHeight(model.cardContent, typography: typography)
        
        let tagModels: [WrittenTagModel] = model.tags.map { tag in
            WrittenTagModel(tag.id, originalText: tag.title, typography: typography)
        }
        self.tags.setModels(tagModels)
        
        self.setLikeAndCommentHidden(showsLikeAndCommentView == false)
        self.likeAndCommentView.isLikeSelected = model.isLike
        self.likeAndCommentView.likeCount = model.likeCnt
        self.likeAndCommentView.commentCount = model.commentCnt
        self.likeAndCommentView.visitedCount = "\(model.visitedCnt)"
    }
    
    func isDeleted() {
        
        self.memberInfoView.updateViewsWhenDeleted()
        self.likeAndCommentView.updateViewsWhenDeleted()
        self.backgroundImageView.removeFromSuperview()
        self.tags.removeFromSuperview()
        
        self.deletedCardInDetailBackgroundView.isHidden = false
    }
    
    func animateLikeUpdate(from previousLikeCount: Int, to currentLikeCount: Int, isSelected: Bool) {
        self.likeAndCommentView.animateLikeUpdate(
            from: previousLikeCount,
            to: currentLikeCount,
            isSelected: isSelected
        )
    }

    func setLikeAndCommentHidden(_ isHidden: Bool) {
        self.likeAndCommentView.isHidden = isHidden
        self.likeAndCommentHeightConstraint?.update(offset: isHidden ? 0 : Layout.likeAndCommentHeight)
    }
    
    static func typography(for font: BaseCardInfo.Font) -> Typography {
        switch font {
        case .pretendard:   return .som.v2.body1
        case .ridi:         return .som.v2.ridiCard
        case .yoonwoo:      return .som.v2.yoonwooCard
        case .kkookkkook:   return .som.v2.kkookkkookCard
        }
    }
    
    static func contentBackgroundHeight(
        for content: String,
        typography: Typography,
        cardWidth: CGFloat
    ) -> CGFloat {
        let textWidth = max(cardWidth - Layout.textHorizontalInset * 2, 0)
        let textHeight = Self.textHeight(for: content, typography: typography, width: textWidth)
        return textHeight + Layout.textContainerVerticalInset * 2
    }
    
    private static func textHeight(
        for content: String,
        typography: Typography,
        width: CGFloat
    ) -> CGFloat {
        let constrainedWidth = max(width, 0)
        guard constrainedWidth > 0 else { return Layout.minimumTextHeight }
        
        let label = UILabel(frame: .init(
            origin: .zero,
            size: .init(width: constrainedWidth, height: .greatestFiniteMagnitude)
        )).then {
            $0.text = content
            $0.textColor = .som.v2.white
            $0.typography = typography
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
            $0.lineBreakStrategy = .hangulWordPriority
            $0.sizeToFit()
        }
        
        return max(ceil(label.frame.height), Layout.minimumTextHeight)
    }
}
