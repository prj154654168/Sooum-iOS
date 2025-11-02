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
    
    static let cellIdentifier = String(reflecting: DetailViewFooterCell.self)
    
    
    // MARK: Views
    
    private let cardView = SOMCard()
    
    
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
        
        self.cardView.prepareForReuse()
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.cardView)
        self.cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    
    // MARK: Public func
    
    func bind(_ model: BaseCardInfo) {
        self.cardView.setModel(model: model)
    }
}
