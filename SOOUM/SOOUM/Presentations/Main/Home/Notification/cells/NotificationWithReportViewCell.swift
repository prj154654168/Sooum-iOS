//
//  NotificationWithReportViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 12/20/24.
//

import UIKit

import SnapKit
import Then


class NotificationWithReportViewCell: UITableViewCell {
    
    static let cellIdentifier = String(reflecting: NotificationWithReportViewCell.self)
    
    enum Text {
        static let blockTypeText: String = "[정지]"
        static let deleteTypeText: String = "[삭제]"
        
        static let blockTitleText: String = "까지 글쓰기가 제한되었습니다."
        static let deleteTitleText: String = "신고로 인해 카드가 삭제 처리 되었습니다."
    }
    
    private let typeLabel = UILabel().then {
        $0.textColor = .som.red
        $0.textAlignment = .center
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 12, weight: .medium),
            lineHeight: 17,
            letterSpacing: -0.004
        )
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.gray700
        $0.textAlignment = .center
        $0.typography = .som.body3WithBold
    }
    
    private let timeGapLabel = UILabel().then {
        $0.textColor = .som.gray400
        $0.textAlignment = .center
        $0.typography = .som.body3WithRegular
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.typeLabel)
        self.typeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.typeLabel.snp.trailing).offset(2)
        }
        
        self.contentView.addSubview(self.timeGapLabel)
        self.timeGapLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(self.titleLabel.snp.trailing)
            $0.trailing.equalToSuperview().offset(-26)
        }
    }
    
    func bind(_ model: CommentHistoryInNoti) {
        
        var typeText: String {
            switch model.type {
            case .blocked: return Text.blockTypeText
            case .delete: return Text.deleteTypeText
            default: return ""
            }
        }
        self.typeLabel.text = typeText
        
        var titleText: String {
            switch model.type {
            case .blocked: return (model.blockExpirationTime ?? Date()).banEndFormatted + Text.blockTitleText
            case .delete: return Text.deleteTitleText
            default: return ""
            }
        }
        self.titleLabel.text = titleText
        
        self.timeGapLabel.text = model.createAt.toKorea().infoReadableTimeTakenFromThis(to: Date().toKorea())
    }
}
