//
//  NoticeViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 9/26/25.
//

import UIKit

import SnapKit
import Then


class NoticeViewCell: UITableViewCell {
    
    enum Text {
        static let title: String = "공지사항"
    }
    
    static let cellIdentifier = String(reflecting: NoticeViewCell.self)
    
    
    // MARK: Views
    
    private let iconView = UIImageView()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption2
    }
    
    private let timeLabel = UILabel().then {
        $0.textColor = .som.gray400
        $0.typography = .som.v2.caption2
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = .som.v2.gray600
        $0.typography = .som.v2.subtitle1.withAlignment(.left)
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }
    
    
    // MARK: Override func
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        let titleContinaer = UIView()
        self.contentView.addSubview(titleContinaer)
        titleContinaer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        titleContinaer.addSubview(self.iconView)
        self.iconView.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.size.equalTo(16)
        }
        
        titleContinaer.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalTo(self.iconView.snp.trailing).offset(8)
        }
        
        titleContinaer.addSubview(self.timeLabel)
        self.timeLabel.snp.makeConstraints {
            $0.verticalEdges.trailing.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(self.titleLabel.snp.trailing).offset(8)
        }
        
        self.contentView.addSubview(self.contentLabel)
        self.contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleContinaer.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-16)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-24)
        }
    }
    
    func bind(_ model: NoticeInfo) {
        
        self.iconView.image = model.noticeType.image
        self.iconView.tintColor = model.noticeType.tintColor
        
        self.titleLabel.text = model.noticeType.title
        self.titleLabel.typography = .som.v2.caption2
    
        self.timeLabel.text = model.createdAt.noticeFormatted
        self.timeLabel.typography = .som.v2.caption2
        
        self.contentLabel.text = model.message
        self.contentLabel.typography = .som.v2.subtitle1.withAlignment(.left)
    }
}
