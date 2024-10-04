//
//  MainHomeViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 10/3/24.
//

import UIKit

import SnapKit
import Then


class MainHomeViewCell: UITableViewCell {
    
    let cardView = SOMCard()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.clipsToBounds = true
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.cardView)
        self.cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setModel(_ model: SOMCardModel) {
        self.cardView.setModel(model: model)
    }
    
    /// 컨텐츠 모드에 따라 정보 스택뷰 순서 변경
    func changeOrderInCardContentStack(_ selectedIndex: Int) {
        self.cardView.changeOrderInCardContentStack(selectedIndex)
    }
}