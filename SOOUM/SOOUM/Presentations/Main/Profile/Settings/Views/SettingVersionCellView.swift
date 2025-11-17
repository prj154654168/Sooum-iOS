//
//  SettingVersionCellView.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then

class SettingVersionCellView: UIView {
    
    
    // MARK: Views
    
    let backgroundButton = UIButton()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.body1
    }
    
    private let latestVersionLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption3
    }
    
    private let currentVersionLabel = UILabel().then {
        $0.text = Info.appVersion
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.body1
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.right))))
        $0.tintColor = .som.gray300
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
        
        self.backgroundColor = .som.v2.white
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(48)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalToSuperview().offset(16)
        }
        
        self.addSubview(self.latestVersionLabel)
        self.latestVersionLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom)
            $0.bottom.equalToSuperview().offset(-6)
            $0.leading.equalToSuperview().offset(16)
        }
        
        self.addSubview(self.arrowImageView)
        self.arrowImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(16)
        }
        
        self.addSubview(self.currentVersionLabel)
        self.currentVersionLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(self.arrowImageView.snp.leading).offset(-10)
        }
        
        self.addSubview(self.backgroundButton)
        self.backgroundButton.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.top)
            $0.bottom.equalTo(self.latestVersionLabel.snp.bottom)
            $0.leading.equalTo(self.titleLabel.snp.leading)
            $0.trailing.equalTo(self.arrowImageView.snp.trailing)
        }
    }
    
    
    // MAKR: Public func
    func setLatestVersion(_ latestVersion: String) {
        
        self.latestVersionLabel.text = latestVersion
        self.latestVersionLabel.typography = .som.v2.caption3
    }
}
