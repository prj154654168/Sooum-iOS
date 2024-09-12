//
//  SOMCardTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 9/12/24.
//

import Then
import UIKit

class SOMCardTableViewCell: UITableViewCell {
    
    /// homeSelect 값에 따라 스택뷰 순서 변함
    enum Mode {
        case latest
        case interest
        case distance
    }
    
    /// 카드 펑 남은시간 표시 라벨
    let cardPungTimeLabel = UILabel().then {
        $0.font = Pretendard(size: 14, weight: .bold).font
        $0.textColor = .som.white
        $0.backgroundColor = .som.blue900
    }
    
    /// cardTextContentLabel를 감싸는 불투명 컨테이너 뷰
    let cardTextContainerView = UIView().then {
        $0.backgroundColor = .som.dim
    }
    
    /// 본문 표시 라벨
    let cardTextContentLabel = UILabel().then {
        $0.font = Pretendard(size: 16, weight: .bold).font
        $0.textColor = .som.white
    }
    
    /// 좋아요, 거리, 댓글, 시간 정보 포함하는 스택뷰
    let cardContentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
    }
    
    /// 시간 정보 표시 스택뷰
    let timeInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    let timeImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.clock)))
    }
    
    let timeLabel = UILabel().then {
        $0.font = Pretendard(size: 10, weight: .bold).font
        $0.textColor = .som.white
    }
    
    /// 거리 정보 표시 스택뷰
    let distanceInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    let distanceImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.location)))
    }
    
    let distanceLabel = UILabel().then {
        $0.font = Pretendard(size: 10, weight: .bold).font
        $0.textColor = .som.white
    }
    
    /// 좋아요 정보 표시 스택뷰
    let likeInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    let likeImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.location)))
    }
    
    let likeLabel = UILabel().then {
        $0.font = Pretendard(size: 10, weight: .bold).font
        $0.textColor = .som.white
    }
    
    /// 댓글 정보 표시 스택뷰
    let commentInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    let commentImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.location)))
    }
    
    let commentLabel = UILabel().then {
        $0.font = Pretendard(size: 10, weight: .bold).font
        $0.textColor = .som.white
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initView
    private func initView() {
        addSubviews()
        initConstraint()
    }
    
    private func addSubviews() {
        addCardPungTimeLabel()
        addCardTextContainerView()
        addCardContentStackView()
    }
    
    private func addCardPungTimeLabel() {
        contentView.addSubview(cardPungTimeLabel)
    }
    
    private func addCardTextContainerView() {
        cardTextContainerView.addSubview(cardTextContentLabel)
        contentView.addSubview(cardTextContainerView)
    }
    
    private func addCardContentStackView() {
        cardContentStackView.addArrangedSubviews(
            timeInfoStackView,
            distanceInfoStackView,
            likeInfoStackView,
            commentInfoStackView
        )
        
        addTimeInfoStackView()
        addDistanceInfoStackView()
        addLikeInfoStackView()
        addCommentInfoStackView()
        
        contentView.addSubview(cardTextContainerView)
    }
    
    private func addTimeInfoStackView() {
        timeInfoStackView.addArrangedSubviews(timeImageView, timeLabel)
    }
    
    private func addDistanceInfoStackView() {
        distanceInfoStackView.addArrangedSubviews(distanceImageView, distanceLabel)
    }
    
    private func addLikeInfoStackView() {
        likeInfoStackView.addArrangedSubviews(likeImageView, likeLabel)
    }
    
    private func addCommentInfoStackView() {
        commentInfoStackView.addArrangedSubviews(commentImageView, commentLabel)
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        cardPungTimeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.height.equalTo(24)
            $0.bottom.equalTo(cardTextContainerView.snp.top).offset(20)
        }
        
        cardTextContainerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        cardTextContentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(10)
        }
        
        cardContentStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.height.equalTo(12)
        }
        
    }

}
