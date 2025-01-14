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
    
    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.typography = .som.caption
        $0.textColor = .som.gray600
    }
    var title: String? {
        set { self.titleLabel.text = newValue }
        get { self.titleLabel.text }
    }
    
    private let imageView = UIImageView().then {
        $0.tintColor = .som.gray600
    }
    var image: UIImage? {
        didSet { self.imageView.image = self.image }
    }
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 50 * 0.5
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let container = UIStackView(arrangedSubviews: [self.imageView, self.titleLabel]).then {
            $0.axis = .vertical
            $0.alignment = .center
        }
        self.backgroundView.addSubview(container)
        container.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        self.imageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        self.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func tabBarItemSelected() {
        
        self.titleLabel.textColor = .som.white
        self.imageView.tintColor = .som.white
        self.backgroundView.backgroundColor = .som.p300
    }
    
    func tabBarItemNotSelected() {
        
        self.titleLabel.textColor = .som.gray600
        self.imageView.tintColor = .som.gray600
        self.backgroundView.backgroundColor = .clear
    }
}
