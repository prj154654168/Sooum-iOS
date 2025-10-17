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
        
        var title: String {
            switch self {
            case .distanceShare: return "거리공유"
            case .story:        return "24시간"
            }
        }
    }
    
    
    // MARK: Views
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption2
    }
    
    
    // MARK: Variables
    
    var isSelected: Bool = false {
        didSet {
            self.backgroundColor = self.isSelected ? .som.v2.pLight1 : .som.v2.gray100
            self.titleLabel.textColor = self.isSelected ? .som.v2.gray600 : .som.v2.gray400
        }
    }
    
    var optionType: OptionType?
    
    // MARK: Initialize
    
    convenience init(type: OptionType) {
        self.init(frame: .zero)
        
        self.optionType = type
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
        
        self.backgroundColor = .som.v2.gray100
        self.layer.cornerRadius = 32 * 0.5
        self.clipsToBounds = true
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(7)
            $0.bottom.equalToSuperview().offset(-7)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
    }
}
