//
//  SOMPageView.swift
//  SOOUM
//
//  Created by 오현식 on 10/2/25.
//

import UIKit

import SnapKit
import Then

class SOMPageView: UICollectionViewCell {
    
    
    // MARK: Views
    
    private let indicatorContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 2
    }
    
    private let iconView = UIImageView()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption2.withAlignment(.left)
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .som.v2.gray600
        $0.typography = .som.v2.subtitle3.withAlignment(.left)
    }
    
    
    // MARK: Variables
    
    private(set) var model: SOMPageModel?
    
    
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
        
        self.contentView.addSubview(self.indicatorContainer)
        self.indicatorContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        let iconBackgroundView = UIView().then {
            $0.backgroundColor = .som.v2.gray100
            $0.layer.cornerRadius = 8
        }
        iconBackgroundView.addSubview(self.iconView)
        self.iconView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(20)
        }
        self.contentView.addSubview(iconBackgroundView)
        iconBackgroundView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(28)
        }
        
        let contentsContainer = UIStackView(arrangedSubviews: [self.titleLabel, self.messageLabel]).then {
            $0.axis = .vertical
        }
        self.contentView.addSubview(contentsContainer)
        contentsContainer.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconBackgroundView.snp.trailing).offset(10)
            $0.trailing.greaterThanOrEqualToSuperview().offset(-16)
        }
    }
    
    
    // MARK: Public func
    
    func setModel(_ model: SOMPageModel) {
        
        self.model = model
        
        self.iconView.image = model.data.noticeType.image
        self.iconView.tintColor = model.data.noticeType.tintColor
        
        self.titleLabel.text = model.data.noticeType.title
        self.titleLabel.typography = .som.v2.caption2.withAlignment(.left)
        self.messageLabel.text = model.data.message
        self.messageLabel.typography = .som.v2.subtitle3.withAlignment(.left)
        
        self.indicatorContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for index in 0..<model.index.total {
            let indicator = UIView().then {
                $0.backgroundColor = model.index.current == index ? .som.v2.gray600 : .som.v2.gray300
                $0.layer.cornerRadius = 4 * 0.5
            }
            self.indicatorContainer.addArrangedSubview(indicator)
            indicator.snp.makeConstraints {
                $0.width.equalTo(model.index.current == index ? 8 : 4)
                $0.height.equalTo(4)
            }
        }
    }
}
