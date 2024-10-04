//
//  DetailViewFooterCell.swift
//  SOOUM
//
//  Created by 오현식 on 10/3/24.
//

import UIKit

import SnapKit
import Then


class DetailViewFooterCell: UICollectionViewCell {
    
    let cardView = SOMCard()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
}
