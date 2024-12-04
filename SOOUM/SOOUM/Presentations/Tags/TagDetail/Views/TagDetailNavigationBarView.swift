//
//  TagDetailNavigationBarView.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

class TagDetailNavigationBarView: UIView {
    
    let backButton = UIButton().then {
        $0.setImage(.arrowBackOutlined, for: .normal)
        $0.tintColor = .som.black
    }
    
    let titleLabel = UILabel().then {
        $0.typography = .som.body2WithBold
    }
    
    let subtitleLabel = UILabel().then {
        $0.typography = .som.body3WithBold
    }
    
    let favoriteButton = UIImageView().then {
        $0.image = .starOutlined
        $0.tintColor = .som.black
    }

    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .som.white
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupConstraints
    private func setupConstraints() {
        self.snp.makeConstraints {
            $0.height.equalTo(77)
        }
        
        self.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-18)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
    }
}
