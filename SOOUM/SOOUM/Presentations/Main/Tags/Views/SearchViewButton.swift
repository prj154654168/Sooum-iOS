//
//  SearchViewButton.swift
//  SOOUM
//
//  Created by 오현식 on 11/19/25.
//

import UIKit

import SnapKit
import Then

class SearchViewButton: UIView {
    
    // MARK: Views
    
    let backgroundButton = UIButton()
    
    private let iconView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.search))))
        $0.tintColor = .som.v2.gray400
    }
    
    private let placeholderLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.subtitle1.withAlignment(.left)
    }
    
    
    // MARK: Variables
    
    var placeholder: String? {
        set {
            self.placeholderLabel.text = newValue
            self.placeholderLabel.typography = .som.v2.subtitle1.withAlignment(.left)
        }
        get {
            return self.placeholderLabel.text
        }
    }
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        let backgroundView = UIView().then {
            $0.backgroundColor = .som.v2.gray100
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
        }
        self.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        backgroundView.addSubview(self.iconView)
        self.iconView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(18)
        }
        
        backgroundView.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.iconView.snp.trailing).offset(10)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        self.addSubview(self.backgroundButton)
        self.backgroundButton.snp.makeConstraints {
            $0.edges.equalTo(backgroundView.snp.edges)
        }
    }
}
