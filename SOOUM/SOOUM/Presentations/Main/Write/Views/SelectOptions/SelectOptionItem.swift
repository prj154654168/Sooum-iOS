//
//  SelectOptionItem.swift
//  SOOUM
//
//  Created by 오현식 on 10/11/25.
//

import UIKit

import SnapKit
import Then

class SelectOptionItem: UIView {
    
    enum OptionType: CaseIterable {
        case distanceShare
        case story
        case vote
        
        var icon: UIImage {
            switch self {
            case .distanceShare: return .v2LocationOutlined
            case .story:        return .v2TimerOutlined
            case .vote:         return .v2VoteOutlined
            }
        }
        
        var title: String {
            switch self {
            case .distanceShare: return "거리공유"
            case .story:        return "24시간"
            case .vote:         return "투표"
            }
        }
    }
    
    
    // MARK: Views
    
    private let iconImageView = UIImageView().then {
        $0.tintColor = .som.v2.gray400
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption2
    }
    
    
    // MARK: Variables
    
    var isSelected: Bool = false {
        didSet {
            self.updateAppearance()
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            self.updateAppearance()
        }
    }
    
    var optionType: OptionType?
    
    // MARK: Initialize
    
    convenience init(type: OptionType) {
        self.init(frame: .zero)
        
        self.optionType = type
        self.iconImageView.image = type.icon
        self.titleLabel.text = type.title
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
        
        self.layer.cornerRadius = 32 * 0.5
        self.clipsToBounds = true
        self.updateAppearance()
        
        self.addSubview(self.iconImageView)
        self.iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.equalToSuperview().offset(10)
            $0.size.equalTo(16)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(7)
            $0.bottom.equalToSuperview().offset(-7)
            $0.leading.equalTo(self.iconImageView.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().offset(-10)
        }
    }
    
    private func updateAppearance() {
        self.backgroundColor = self.isEnabled
            ? (self.isSelected ? .som.v2.pLight1 : .som.v2.gray100)
            : .som.v2.gray200
        self.iconImageView.tintColor = self.isSelected ? .som.v2.gray600 : .som.v2.gray400
        self.titleLabel.textColor = self.isSelected ? .som.v2.gray600 : .som.v2.gray400
    }
}
