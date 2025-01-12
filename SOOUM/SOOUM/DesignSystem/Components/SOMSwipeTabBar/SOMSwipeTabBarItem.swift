//
//  SOMSwipeTabBarItem.swift
//  SOOUM
//
//  Created by 오현식 on 12/22/24.
//

import UIKit

import SnapKit
import Then


class SOMSwipeTabBarItem: UIView {
    
    private let titleLabel = UILabel()
    
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
    
    private func setupConstraints() {
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func updateState(
        color textColor: UIColor,
        typo typography: Typography,
        with duration: TimeInterval
    ) {
        
        UIView.animate(withDuration: duration) {
            self.titleLabel.textColor = textColor
            self.titleLabel.typography = typography
        }
    }
}
