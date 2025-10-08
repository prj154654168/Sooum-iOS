//
//  SOMStickyTabBarItem.swift
//  SOOUM
//
//  Created by 오현식 on 12/22/24.
//

import UIKit

import SnapKit
import Then


class SOMStickyTabBarItem: UIView {
    
    
    // MARK: Views
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.title2
    }
    
    private let selectedIndicator = UIView().then {
        $0.backgroundColor = .som.v2.black
        $0.isHidden = true
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
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.horizontalEdges.equalToSuperview()
        }
        
        self.addSubview(self.selectedIndicator)
        self.selectedIndicator.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
    
    
    // MARK: Public func
    
    func updateState(color textColor: UIColor, hasIndicator: Bool) {
        
        self.titleLabel.textColor = textColor
        self.selectedIndicator.isHidden = hasIndicator == false
    }
}
