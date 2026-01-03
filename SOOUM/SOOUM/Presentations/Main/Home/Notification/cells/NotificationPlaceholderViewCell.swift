//
//  NotificationPlaceholderViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 1/9/25.
//

import UIKit

import SnapKit
import Then


class NotificationPlaceholderViewCell: UITableViewCell {
    
    enum Text {
        static let placeholderLabelText: String = "아직 표시할 알림이 없어요\n활동 알림은 30일 후, 자동 삭제돼요"
    }
    
    static let cellIdentifier = String(reflecting: NotificationPlaceholderViewCell.self)
    
    
    // MARK: Views
    
    private let placeholderImage = UIImageView().then {
        $0.image = .init(.image(.v2(.placeholder_notification)))
        $0.contentMode = .scaleAspectFit
    }
    
    private let placeholderLabel = UILabel().then {
        $0.text = Text.placeholderLabelText
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.body1
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    
    // MARK: Initalization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.isUserInteractionEnabled = false
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.placeholderImage)
        self.placeholderImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIScreen.main.bounds.height * 0.2)
            $0.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(self.placeholderImage.snp.bottom).offset(20)
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
}
