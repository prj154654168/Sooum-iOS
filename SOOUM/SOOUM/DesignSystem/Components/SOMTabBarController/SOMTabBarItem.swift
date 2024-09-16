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
    
    static let width: CGFloat = 50
    static let height: CGFloat = 52
    
    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.typography = .init(fontContainer: Pretendard(size: 10, weight: .medium), lineHeight: 12)
        $0.textColor = .som.gray01
    }
    var title: String? {
        set { self.titleLabel.text = newValue }
        get { self.titleLabel.text }
    }
    
    private let imageView = UIImageView().then {
        $0.tintColor = .som.gray01
    }
    var image: UIImage? {
        didSet { self.imageView.image = self.image }
    }
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 52 * 0.5
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
        self.titleLabel.typography = .init(
            fontContainer: Pretendard(size: 10, weight: .bold),
            lineHeight: 12
        )
        self.imageView.tintColor = .som.white
        self.backgroundView.backgroundColor = .som.primary
    }
    
    func tabBarItemNotSelected() {
        
        // TODO: 추후 DesignSystem의 Foundation이 정리되면 수정 (typography)
        self.titleLabel.textColor = .som.gray01
        self.titleLabel.typography = .init(
            fontContainer: Pretendard(size: 10, weight: .medium),
            lineHeight: 12
        )
        self.imageView.tintColor = .som.gray01
        self.backgroundView.backgroundColor = .clear
    }
}
