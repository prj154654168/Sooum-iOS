//
//  SettingTextCellView.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then

class SettingTextCellView: UIView {
    
    // MARK: Views
    
    let backgroundButton = UIButton()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.black
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
        
        self.setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        
        let backgroundView = UIView()
        self.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        backgroundView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
        }
        
        backgroundView.addSubview(self.arrowImageView)
        self.arrowImageView.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
            $0.size.equalTo(16)
        }
        
        self.addSubview(self.backgroundButton)
        self.bringSubviewToFront(self.backgroundButton)
        self.backgroundButton.snp.makeConstraints {
            $0.edges.equalTo(backgroundView)
        }
    }
}
