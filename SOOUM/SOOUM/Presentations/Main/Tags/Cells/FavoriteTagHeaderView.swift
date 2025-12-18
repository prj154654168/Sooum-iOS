//
//  FavoriteTagHeaderView.swift
//  SOOUM
//
//  Created by 오현식 on 11/20/25.
//

import UIKit

import SnapKit
import Then

class FavoriteTagHeaderView: UIView {
    
    // MARK: Views
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.title1
    }
    
    
    // MARK: Varaibles
    
    var title: String? {
        set {
            self.titleLabel.text = newValue
            self.titleLabel.typography = .som.v2.title1
        }
        get {
            return self.titleLabel.text
        }
    }
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.snp.makeConstraints {
            $0.height.equalTo(59)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
    }
}
