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
    
    enum Text {
        static let cardTitle: String = "카드"
        static let feedLikeContents: String = "님이 회원님의 카드에 좋아요를 남겼어요."
        static let commentLikeContents: String = "님이 회원님의 댓글카드에 좋아요를 남겼어요."
        static let commentWriteContents: String = "님이 댓글카드를 남겼어요. 알림을 눌러 대화를 이어가 보세요."
        
        static let followTitle: String = "팔로우"
        static let followContents: String = "님이 회원님을 팔로우하기 시작했어요."
        
        static let deletedAndBlockedTitle: String = "제한"
        static let deletedContents: String = "운영정책 위반으로 인해 작성된 카드가 삭제 처리되었습니다."
        static let blockedLeadingContents: String = "운영정책 위반으로 인해 "
        static let blockedTrailingContents: String = "까지 카드추가가 제한됩니다."
        
        static let tagTitle: String = "태그"
        static let tagContents: String = "태그가 포함된 카드가 올라왔어요."
    }
    
    static let cellIdentifier = String(reflecting: NotificationViewCell.self)
    
    
    // MARK: Views
    
    private let iconView = UIImageView()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
    }
    
    private let timeGapLabel = UILabel().then {
        $0.textColor = .som.gray400
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = .som.v2.gray600
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = nil
        self.timeGapLabel.text = nil
        self.contentLabel.text = nil
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
        
        titleContinaer.addSubview(self.timeGapLabel)
        self.timeGapLabel.snp.makeConstraints {
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
    
    func bind(_ model: CompositeNotificationInfo, isReaded: Bool) {
        
        self.backgroundColor = isReaded ? .som.v2.white : .som.v2.pLight1
        
        var iconInfo: (image: UIImage?, color: UIColor)? {
            switch model {
            case .default:
                return (.init(.icon(.v2(.filled(.card)))), .som.v2.pMain)
            case .follow:
                return (.init(.icon(.v2(.filled(.users)))), .som.v2.pMain)
            case .deleted, .blocked:
                return (.init(.icon(.v2(.filled(.danger)))), .som.v2.yMain)
            case .tag:
                return (.init(.icon(.v2(.filled(.tag)))), .som.v2.pMain)
            }
        }
        
        var titleInfo: (text: String, typography: Typography)? {
            let typography = isReaded ? Typography.som.v2.caption2 : Typography.som.v2.caption1
            switch model {
            case .default:
                return (Text.cardTitle, typography)
            case .follow:
                return (Text.followTitle, typography)
            case .deleted:
                return (Text.deletedAndBlockedTitle, typography)
            case .blocked:
                return (Text.deletedAndBlockedTitle, typography)
            case .tag:
                return (Text.tagTitle, typography)
            }
        }
        
        var timeGapInfo: (text: String, typography: Typography)? {
            let typography = isReaded ? Typography.som.v2.caption2 : Typography.som.v2.caption1
            switch model {
            case let .default(notification):
                let timeGapText = notification.notificationInfo.createTime.toKorea().infoReadableTimeTakenFromThis(to: Date().toKorea())
                return (timeGapText, typography)
            case let .follow(notification):
                let timeGapText = notification.notificationInfo.createTime.toKorea().infoReadableTimeTakenFromThis(to: Date().toKorea())
                return (timeGapText, typography)
            case let .deleted(notification):
                let timeGapText = notification.notificationInfo.createTime.toKorea().infoReadableTimeTakenFromThis(to: Date().toKorea())
                return (timeGapText, typography)
            case let .blocked(notification):
                let timeGapText = notification.notificationInfo.createTime.toKorea().infoReadableTimeTakenFromThis(to: Date().toKorea())
                return (timeGapText, typography)
            case let .tag(notification):
                let timeGapText = notification.notificationInfo.createTime.toKorea().infoReadableTimeTakenFromThis(to: Date().toKorea())
                return (timeGapText, typography)
            }
        }
        
        var contentsInfo: (text: String, typography: Typography)? {
            let typography = isReaded ? Typography.som.v2.subtitle1.withAlignment(.left) : Typography.som.v2.title2.withAlignment(.left)
            switch model {
            case let .default(notification):
                switch notification.notificationInfo.notificationType {
                case .feedLike:
                    return ("\(notification.nickName)\(Text.feedLikeContents)", typography)
                case .commentLike:
                    return ("\(notification.nickName)\(Text.commentLikeContents)", typography)
                case .commentWrite:
                    return ("\(notification.nickName)\(Text.commentWriteContents)", typography)
                default:
                    return nil
                }
            case let .follow(notification):
                return ("\(notification.nickname)\(Text.followContents)", typography)
            case .deleted:
                return (Text.deletedContents, typography)
            case let .blocked(notification):
                let text = "\(Text.blockedLeadingContents)\(notification.blockExpirationDateTime.banEndFormatted)\(Text.blockedTrailingContents)"
                return (text, typography)
            case let .tag(notification):
                return ("‘\(notification.tagContent)’ \(Text.tagContents)", typography)
            }
        }
        
        if let iconInfo = iconInfo {
            self.iconView.image = iconInfo.image
            self.iconView.tintColor = iconInfo.color
        }
        
        if let titleInfo = titleInfo {
            self.titleLabel.text = titleInfo.text
            self.titleLabel.typography = titleInfo.typography
        }
        
        if let timeGapInfo = timeGapInfo {
            self.timeGapLabel.text = timeGapInfo.text
            self.timeGapLabel.typography = timeGapInfo.typography
        }
        
        if let contentsInfo = contentsInfo {
            self.contentLabel.text = contentsInfo.text
            self.contentLabel.typography = contentsInfo.typography
        }
    }
}
