//
//  FloatingButton.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import UIKit

import SnapKit
import Then

class FloatingButton: UIView {
    
    
    // MARK: Views
    
    let backgoundButton = UIButton()
    
    private let shadowbackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.gray600
        $0.layer.cornerRadius = 56 * 0.5
    }
    
    private let imageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.plus))))
        $0.tintColor = .som.v2.white
    }
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.shadowbackgroundView.setShadow(
            radius: 0,
            color: UIColor(hex: "#64686C33").withAlphaComponent(0.2),
            blur: 12,
            offset: .init(width: 0, height: 8)
        )
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.snp.makeConstraints {
            $0.size.equalTo(56)
        }
        
        self.addSubview(self.shadowbackgroundView)
        self.shadowbackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.addSubview(self.backgoundButton)
        self.backgoundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
