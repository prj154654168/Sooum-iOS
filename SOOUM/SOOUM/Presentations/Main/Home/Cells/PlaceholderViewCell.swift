//
//  PlaceholderViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 12/30/24.
//

import UIKit

import SnapKit
import Then


class PlaceholderViewCell: UITableViewCell {
    
    enum Text {
        static let title: String = "아직 등록된 카드가 없어요"
        static let firstSubTitle: String = "사소하지만 말 못 한 이야기를"
        static let secondSubTitle: String = "카드로 만들어 볼까요?"
    }
    
    
    // MARK: Views
    
    private let placeholderTitleLabel = UILabel().then {
        $0.text = Text.title
        $0.textColor = .som.black
        $0.textAlignment = .center
        $0.typography = .som.body1WithBold
    }
    
    private let placeholderFirstSubTitleLabel = UILabel().then {
        $0.text = Text.firstSubTitle
        $0.textColor = .som.gray500
        $0.textAlignment = .center
        $0.typography = .som.body2WithBold
    }
    
    private let placeholderSecondSubTitleLabel = UILabel().then {
        $0.text = Text.secondSubTitle
        $0.textColor = .som.gray500
        $0.textAlignment = .center
        $0.typography = .som.body2WithBold
    }
    
    
    // MARK: Initalization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.placeholderTitleLabel)
        self.placeholderTitleLabel.snp.makeConstraints {
            let offset = UIScreen.main.bounds.height * 0.2
            $0.top.equalToSuperview().offset(offset)
            $0.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(self.placeholderFirstSubTitleLabel)
        self.placeholderFirstSubTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.placeholderTitleLabel.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(self.placeholderSecondSubTitleLabel)
        self.placeholderSecondSubTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.placeholderFirstSubTitleLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
}
