//
//  AnnouncementTextCellView.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then


class AnnouncementTextCellView: UIView {
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.gray500
        $0.typography = .som.body2WithBold
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = .init(.image(.next))
        $0.tintColor = .som.gray400
    }
    
    let backgroundButton = UIButton()
    
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
        
        self.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(73)
        }
        
        let bottomSeperator = UIView().then {
            $0.backgroundColor = .som.gray200
        }
        self.addSubview(bottomSeperator)
        bottomSeperator.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.addSubview(self.arrowImageView)
        self.arrowImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-24)
            $0.size.equalTo(24)
        }
        
        self.addSubview(self.backgroundButton)
        self.backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
