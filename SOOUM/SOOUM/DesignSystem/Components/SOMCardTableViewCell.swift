//
//  SOMCardTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 9/12/24.
//

import UIKit
import Then

class SOMCardTableViewCell: UITableViewCell {
    
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
        cardContentStackView.addSubview(cardTextContentLabel)
        contentView.addSubview(cardTextContainerView)
    }
        
}
