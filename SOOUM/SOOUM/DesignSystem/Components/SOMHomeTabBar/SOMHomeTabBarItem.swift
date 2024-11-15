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
        $0.typography = .som.body2WithBold
    }
    
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
        
        let backgrounView = UIView()
        self.addSubviews(backgrounView)
        backgrounView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        backgrounView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
        }
    }
    
    func updateItemColor(_ isSelected: Bool) {
        self.titleLabel.textColor = isSelected ? .som.black : .som.gray600
    }
}
