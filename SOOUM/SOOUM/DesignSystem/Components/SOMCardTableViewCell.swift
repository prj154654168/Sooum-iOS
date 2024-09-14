//
//  SOMCardTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 9/12/24.
//

import SnapKit
import Then
import UIKit

class SOMCardTableViewCell: UITableViewCell {
//    모델은 대충 만들기
//    펑 구현 인터벌 사용
    
    /// homeSelect 값에 따라 스택뷰 순서 변함
    enum Mode {
        case latest
        case interest
        case distance
    }
    
    /// 카드 펑 타임
    var pungTime: Date?
    
    let cardView = SOMCard()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - initView
    private func initView() {
        self.selectionStyle = .none
        addSubviews()
        initConstraint()
    }
    
    private func addSubviews() {
        contentView.addSubview(cardView)
    }

    // MARK: - initConstraint
    private func initConstraint() {
        cardView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
