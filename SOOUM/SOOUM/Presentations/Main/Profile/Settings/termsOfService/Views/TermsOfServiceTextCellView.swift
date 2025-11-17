//
//  TermsOfServiceTextCellView.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then

class TermsOfServiceTextCellView: UIView {
    
    
    // MARK: Views
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.body1
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.right))))
        $0.tintColor = .som.v2.gray300
    }
    
    let backgroundButton = UIButton()
    
    
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
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(48)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        self.addSubview(self.arrowImageView)
        self.arrowImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(16)
        }
        
        self.addSubview(self.backgroundButton)
        self.backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
