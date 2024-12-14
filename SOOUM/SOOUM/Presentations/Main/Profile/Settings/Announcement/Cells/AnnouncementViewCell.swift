//
//  AnnouncementViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then


class AnnouncementViewCell: UITableViewCell {
    
    enum Text {
        static let announcementText: String = "공지사항"
        static let maintenanceText: String = "점검안내"
    }
    
    private let announcementTypeLabel = UILabel().then {
        $0.textColor = .som.p300
        $0.typography = .som.body2WithBold
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.gray500
        $0.typography = .som.body2WithBold
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = .som.gray500
        $0.typography = .som.body3WithRegular
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.next)))
        $0.tintColor = .som.gray400
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.clipsToBounds = true
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.addSubview(self.announcementTypeLabel)
        self.announcementTypeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(self.announcementTypeLabel.snp.trailing).offset(6)
        }
        
        self.addSubview(self.dateLabel)
        self.dateLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.addSubview(self.arrowImageView)
        self.arrowImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-24)
            $0.size.equalTo(24)
        }
        
        let bottomSeperator = UIView().then {
            $0.backgroundColor = .som.gray200
        }
        self.addSubview(bottomSeperator)
        bottomSeperator.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func setModel(_ model: Announcement) {
        
        self.announcementTypeLabel.text = model.noticeType == .announcement ? Text.announcementText : Text.maintenanceText
        self.titleLabel.text = model.title
        self.dateLabel.text = Date(from: model.noticeDate)?.announcementFormatted
    }
}
