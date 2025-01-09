//
//  NotiPlaceholderViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 1/9/25.
//

import UIKit

import SnapKit
import Then


class NotiPlaceholderViewCell: UITableViewCell {
    
    static let cellIdentifier = String(reflecting: NotiPlaceholderViewCell.self)
    
    enum Text {
        static let placeholderLabelText: String = "알림이 아직 없어요"
    }
    
    
    // MARK: Views
    
    private let placeholderLabel = UILabel().then {
        $0.text = Text.placeholderLabelText
        $0.textColor = .init(hex: "#B4B4B4")
        $0.typography = .som.body1WithBold
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
        
        self.contentView.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIScreen.main.bounds.height * 0.3)
            $0.centerX.equalToSuperview()
        }
    }
}
