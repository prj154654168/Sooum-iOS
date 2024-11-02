//
//  SOMHomeTabBarItem.swift
//  SOOUM
//
//  Created by 오현식 on 9/13/24.
//

import UIKit

import SnapKit
import Then


class SOMHomeTabBarItem: UIView {
    
    static let width: CGFloat = 53
    
    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .som.gray600
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 14, weight: .medium),
            lineHeight: 14,
            letterSpacing: 0.07
        )
    }
    var text: String? {
        set { self.titleLabel.text = newValue }
        get { self.titleLabel.text }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let backgraoundView = UIView()
        
        backgraoundView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview().offset(-6)
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
        }
        
        self.addSubview(backgraoundView)
        backgraoundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func homeTabBarItemSelected() {
        
        self.titleLabel.textColor = .som.black
        self.titleLabel.typography = .init(
            fontContainer: BuiltInFont(size: 14, weight: .bold),
            lineHeight: 14,
            letterSpacing: 0.07
        )
    }
    
    func homeTabBarItemNotSelected() {
        
        self.titleLabel.textColor = .som.gray600
        self.titleLabel.typography = .init(
            fontContainer: BuiltInFont(size: 14, weight: .medium),
            lineHeight: 14,
            letterSpacing: 0.07
        )
    }
}
