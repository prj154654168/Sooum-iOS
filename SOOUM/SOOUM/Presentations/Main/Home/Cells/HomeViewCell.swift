//
//  HomeViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 10/3/24.
//

import UIKit

import SnapKit
import Then


class HomeViewCell: UITableViewCell {
    
    static let cellIdentifier = String(reflecting: HomeViewCell.self)
    
    
    // MARK: Views
    
    let cardView = SOMCard()
    
    
    // MARK: Initialize
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
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
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    
    // MARK: Public info
    
    func bind(_ model: BaseCardInfo) {
        self.cardView.setModel(model: model)
    }
}
