//
//  SOMSwipableTabBarItem.swift
//  SOOUM
//
//  Created by 오현식 on 9/23/25.
//

import UIKit

import SnapKit
import Then


class SOMSwipableTabBarItem: UIView {
    
    
    // MARK: Views
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray600
        $0.typography = .som.v2.subtitle3
    }
    
    private let dotWithoutReadView = UIView().then {
        $0.backgroundColor = .som.v2.rMain
        $0.layer.cornerRadius = 5 * 0.5
        $0.isHidden = true
    }
    
    
    // MARK: Variables
    
    var isEventDotHidden: Bool = true {
        didSet {
            self.dotWithoutReadView.isHidden = self.isEventDotHidden
        }
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
        
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        self.addSubview(self.dotWithoutReadView)
        self.dotWithoutReadView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.trailing.equalToSuperview().offset(-3)
            $0.size.equalTo(5)
        }
    }
    
    func updateState(
        color textColor: UIColor,
        backgroundColor: UIColor? = nil
    ) {
        
        self.titleLabel.textColor = textColor
        self.backgroundColor = backgroundColor ?? .clear
    }
}
