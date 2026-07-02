//
//  DetailVoteCell.swift
//  SOOUM
//
//  Created by 오현식 on 6/30/26.
//

import UIKit

import RxSwift
import SnapKit

final class DetailVoteCell: UICollectionViewCell {

    private enum Layout {
        static let likeAndCommentHeight: CGFloat = 44
    }

    private let votedView = VotedView()
    let likeAndCommentView = LikeAndCommentView()
    var onVoteOptionTap: ((String) -> Void)?
    
    var disposeBag = DisposeBag()
    
    private var likeAndCommentHeightConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
        self.likeAndCommentView.prepareForReuse()
    }

    private func setupConstraints() {
        self.contentView.backgroundColor = .som.v2.white

        self.contentView.addSubview(self.votedView)
        self.votedView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        self.contentView.addSubview(self.likeAndCommentView)
        self.likeAndCommentView.snp.makeConstraints {
            $0.top.equalTo(self.votedView.snp.bottom)
            $0.bottom.horizontalEdges.equalToSuperview()
            self.likeAndCommentHeightConstraint = $0.height.equalTo(0).constraint
        }
    }

    func setModels(_ model: DetailCardInfo, showsLikeAndCommentView: Bool, animatesResult: Bool) {
        self.setLikeAndCommentHidden(showsLikeAndCommentView == false)
        self.likeAndCommentView.isLikeSelected = model.isLike
        self.likeAndCommentView.likeCount = model.likeCnt
        self.likeAndCommentView.commentCount = model.commentCnt
        self.likeAndCommentView.visitedCount = "\(model.visitedCnt)"
        self.votedView.onOptionTap = { [weak self] optionId in
            self?.onVoteOptionTap?(optionId)
        }
        self.votedView.setModels(model.poll, animatesResult: animatesResult)
    }

    func setLikeAndCommentHidden(_ isHidden: Bool) {
        self.likeAndCommentView.isHidden = isHidden
        self.likeAndCommentHeightConstraint?.update(offset: isHidden ? 0 : Layout.likeAndCommentHeight)
    }

    func animateLikeUpdate(from previousLikeCount: Int, to currentLikeCount: Int, isSelected: Bool) {
        self.likeAndCommentView.animateLikeUpdate(
            from: previousLikeCount,
            to: currentLikeCount,
            isSelected: isSelected
        )
    }
}
