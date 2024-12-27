//
//  NotificationViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 12/20/24.
//

import UIKit

import SnapKit
import Then


class NotificationViewCell: UITableViewCell {
    
    static let cellIdentifier = String(reflecting: NotificationViewCell.self)
    
    private let feedCardImageView = UIImageView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    private let feedCardContentLabel = UILabel().then {
        $0.textColor = .som.white
        $0.textAlignment = .center
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 3, weight: .bold),
            lineHeight: 5,
            letterSpacing: -0.04
        )
    }
    
    private let notificationTitleLabel = UILabel().then {
        $0.textColor = .som.gray700
        $0.textAlignment = .center
        $0.typography = .som.body3WithBold
    }
    
    private let timeGapLabel = UILabel().then {
        $0.textColor = .som.gray400
        $0.textAlignment = .center
        $0.typography = .som.body3WithBold
    }
    
    private let dotWithoutReadView = UIView().then {
        $0.backgroundColor = .som.red
        $0.layer.cornerRadius = 6 * 0.5
        $0.clipsToBounds = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.feedCardImageView)
        self.feedCardImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(40)
        }
        
        self.feedCardImageView.addSubview(self.feedCardContentLabel)
        self.feedCardContentLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.contentView.addSubview(self.notificationTitleLabel)
        self.notificationTitleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.feedCardImageView.snp.trailing).offset(20)
        }
        
        self.contentView.addSubview(self.timeGapLabel)
        self.timeGapLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(self.notificationTitleLabel.snp.trailing).offset(9)
            $0.trailing.equalToSuperview().offset(-26)
        }
        
        self.contentView.addSubview(self.dotWithoutReadView)
        self.dotWithoutReadView.snp.makeConstraints {
            $0.top.equalTo(self.timeGapLabel.snp.top)
            $0.leading.equalTo(self.timeGapLabel.snp.trailing)
            $0.size.equalTo(6)
        }
    }
    
    func bind(_ model: CommentHistoryInNoti, isReaded: Bool) {
        
        self.feedCardImageView.setImage(strUrl: model.feedCardImgURL?.url)
        self.feedCardContentLabel.text = model.content
        
        let text: String = {
            switch model.type {
            case .feedLike, .commentLike: return "님이 카드에 공감하였습니다."
            case .commentWrite: return "님이 답카드를 작성했습니다."
            default: return ""
            }
        }()
        self.notificationTitleLabel.text = "\(model.nickName ?? "")\(text)"
        
        self.timeGapLabel.text = model.createAt.toKorea().infoReadableTimeTakenFromThis(to: Date().toKorea())
        
        self.dotWithoutReadView.isHidden = isReaded
    }
}
