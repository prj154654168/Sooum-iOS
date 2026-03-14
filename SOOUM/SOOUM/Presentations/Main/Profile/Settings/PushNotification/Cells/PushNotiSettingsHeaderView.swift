//
//  PushNotiSettingsHeaderViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 3/7/26.
//

import UIKit

import SnapKit
import Then

final class PushNotiSettingsHeaderView: UIView {
    
    
    // MARK: Views
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption1.withAlignment(.left)
    }
    
    
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
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}
