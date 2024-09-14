//
//  SOMCard.swift
//  SOOUM
//
//  Created by JDeoks on 9/14/24.
//

import Foundation
import UIKit

class SOMCard: UIView {
    
    let rootContainerView = UIView().then {
        $0.backgroundColor = .orange
        $0.layer.cornerRadius = 40
    }
    
    let cardPungTimeContainerView = UIView().then {
        $0.backgroundColor = .som.blue300
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    /// 카드 펑 남은시간 표시 라벨
    let cardPungTimeLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 14,
                weight: .bold
            ),
            lineHeight: 16.7,
            letterSpacing: 0
        )
        $0.textColor = .som.white
        $0.text = "14:00:00"
    }
    
    /// cardTextContentLabel를 감싸는 불투명 컨테이너 뷰
    let cardTextContainerView = UIView().then {
        $0.backgroundColor = .som.dim
        $0.layer.cornerRadius = 12
    }
    
    /// 본문 표시 라벨
    let cardTextContentLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 16,
                weight: .bold
            ),
            lineHeight: 28.8,
            letterSpacing: 0
        )
        $0.textColor = .som.white
        $0.numberOfLines = 0
        $0.text = "cardTextContentLabelcardTextContentLabelcardTextContentLabelcardTextContentLabelcardTextContentLabelcardTextContentLabelcardTextContentLabelcardTextContentLabelcardTextContentLabel"
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
        $0.tintColor = .som.white
    }
    
    let timeLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 10,
                weight: .bold
            ),
            lineHeight: 11,
            letterSpacing: 0
        )
        $0.textColor = .som.white
        $0.text = "30분전"
    }
    
    /// 거리 정보 표시 스택뷰
    let distanceInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    let distanceImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.location)))
        $0.tintColor = .som.white
    }
    
    let distanceLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 10,
                weight: .bold
            ),
            lineHeight: 11,
            letterSpacing: 0
        )
        $0.textColor = .som.white
        $0.text = "1km"
    }
    
    /// 좋아요 정보 표시 스택뷰
    let likeInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    let likeImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.heart)))
        $0.tintColor = .som.white
    }
    
    let likeLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 10,
                weight: .bold
            ),
            lineHeight: 11,
            letterSpacing: 0
        )
        $0.textColor = .som.white
        $0.text = "12"
    }
    
    /// 댓글 정보 표시 스택뷰
    let commentInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    let commentImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.comment)))
        $0.tintColor = .som.white
    }
    
    let commentLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
                size: 10,
                weight: .bold
            ),
            lineHeight: 11,
            letterSpacing: 0
        )
        $0.textColor = .som.white
        $0.text = "12"
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        print("\(type(of: self)) - \(#function)")
        super.init(frame: frame)
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
        self.addSubview(rootContainerView)
        addCardPungTimeLabel()
        addCardTextContainerView()
        addCardContentStackView()
    }
    
    private func addCardPungTimeLabel() {
        rootContainerView.addSubview(cardPungTimeContainerView)
        cardPungTimeContainerView.addSubview(cardPungTimeLabel)
    }
    
    private func addCardTextContainerView() {
        cardTextContainerView.addSubview(cardTextContentLabel)
        rootContainerView.addSubview(cardTextContainerView)
    }
    
    private func addCardContentStackView() {
        cardContentStackView.addArrangedSubviews(
            UIView(),
            timeInfoStackView,
            distanceInfoStackView,
            likeInfoStackView,
            commentInfoStackView
        )
        
        addTimeInfoStackView()
        addDistanceInfoStackView()
        addLikeInfoStackView()
        addCommentInfoStackView()
        
        rootContainerView.addSubview(cardContentStackView)
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
        rootContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(5)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(5)
        }
        
        cardPungTimeContainerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(22)
            $0.height.equalTo(24)
            $0.bottom.equalTo(cardTextContainerView.snp.top).offset(-22)
        }
        
        cardPungTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview()
        }
        
        cardTextContainerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(rootContainerView.snp.width).multipliedBy(0.6)
        }
        
        cardTextContentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(-4)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        cardContentStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-24)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-26)
            $0.height.height.equalTo(12)
        }
        
        timeImageView.snp.makeConstraints {
            $0.height.width.equalTo(12)
        }
        
        distanceImageView.snp.makeConstraints {
            $0.height.width.equalTo(12)
        }
        
        likeImageView.snp.makeConstraints {
            $0.height.width.equalTo(12)
        }
        
        commentImageView.snp.makeConstraints {
            $0.height.width.equalTo(12)
        }
    }
}
