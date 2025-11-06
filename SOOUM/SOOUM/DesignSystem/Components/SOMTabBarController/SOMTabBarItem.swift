//
//  SOMTabBarItem.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/24.
//

import UIKit

import SnapKit
import Then


class SOMTabBarItem: UIView {
    
    
    // MARK: Views
    
    private let imageView = UIImageView().then {
        $0.tintColor = .som.v2.gray300
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption2
    }
    
    
    // MARK: Initialize
    
    convenience init(title: String?, image: UIImage?) {
        self.init(frame: .zero)
        
        self.titleLabel.text = title
        self.imageView.image = image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.snp.makeConstraints {
            $0.width.equalTo(77)
            $0.height.equalTo(46)
        }
        
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.imageView.snp.bottom).offset(4)
            $0.bottom.centerX.equalToSuperview()
        }
    }
    
    func tabBarItemSelected() {
        
        self.titleLabel.textColor = .som.v2.black
        self.imageView.tintColor = .som.v2.black
    }
    
    func tabBarItemNotSelected() {
        
        self.titleLabel.textColor = .som.v2.gray400
        self.imageView.tintColor = .som.v2.gray400
    }
}
