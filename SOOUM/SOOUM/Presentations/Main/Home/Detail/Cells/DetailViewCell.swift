//
//  DetailViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 10/3/24.
//

import UIKit

import SnapKit
import Then


class DetailViewCell: UICollectionViewCell {
    
    let cardView = SOMCard()
    
    lazy var tags = SOMTags()
    
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
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            let width: CGFloat = UIScreen.main.bounds.width - 20 * 2
            $0.height.equalTo(width)
        }
        
        self.contentView.addSubview(self.tags)
        self.tags.snp.makeConstraints {
            $0.top.equalTo(self.cardView.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(59)
        }
    }
    
    func setData(_ model: SOMCardModel, tags: [SOMTagModel]) {
        self.cardView.setModel(model: model)
        self.tags.setDatas(tags)
    }
}
