//
//  SOMSwipableTabBarItem.swift
//  SOOUM
//
//  Created by 오현식 on 9/23/25.
//

import UIKit

import SnapKit
import Then


class SOMSwipableTabBarItem: UIView {
    
    
    // MARK: Views
    
    private let titleLabel = UILabel()
    
    
    // MARK: Initialize
    
    convenience init(title: String) {
        self.init(frame: .zero)
        
        self.titleLabel.text = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
    }
    
    func updateState(
        color textColor: UIColor,
        typo typography: Typography,
        backgroundColor: UIColor? = nil
    ) {
        
        self.titleLabel.textColor = textColor
        self.titleLabel.typography = typography
        self.backgroundColor = backgroundColor ?? .clear
    }
}
