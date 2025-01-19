//
//  DialogMessageView.swift
//  SOOUM
//
//  Created by 오현식 on 1/18/25.
//

import UIKit

import SnapKit
import Then


class DialogMessageView: UIView {
    
    static var messageTypo: Typography = .som.body2WithBold
    
    enum Text {
        static let dot: String = "•"
        
        static let banUserDialogFirstMessage: String = "해당 계정은 정지된 이력이 있는 탈퇴 계정 입니다."
        static let resignDialogFirstMessage: String = "탈퇴 시점으로 부터 7일 경과 후 새로운 계정 생성이 가능합니다."
        
        static let dialogSecondLeftMessage: String = "새로운 계정 생성은 "
        static let dialogSecondRightMessage: String = " 이후 가능합니다."
    }
    
    
    // MARK: Views
    
    private let firstDotLabel = UILabel().then {
        $0.text = Text.dot
        $0.textColor = .som.gray600
        $0.typography = .som.body2WithBold
        
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    private let firstMessageLabel = UILabel().then {
        $0.textColor = .som.gray600
        $0.typography = .som.body2WithBold.withAlignment(.left)
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
        $0.numberOfLines = 0
    }
    
    private let secondDotLabel = UILabel().then {
        $0.text = Text.dot
        $0.textColor = .som.gray600
        $0.typography = .som.body2WithBold
        
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    private let secondMessageLabel = UILabel().then {
        $0.textColor = .som.gray600
        $0.typography = .som.body2WithBold.withAlignment(.left)
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
        $0.numberOfLines = 0
    }
    
    
    // MARK: Variables
    
    var firstMessage: String? {
        set {
            self.firstMessageLabel.text = newValue
            self.firstMessageLabel.typography = Self.messageTypo.withAlignment(.left)
        }
        get {
            return self.firstMessageLabel.text
        }
    }
    
    var secondMessage: String? {
        set {
            self.secondMessageLabel.text = newValue
            self.secondMessageLabel.typography = Self.messageTypo.withAlignment(.left)
        }
        get {
            return self.secondMessageLabel.text
        }
    }
    
    
    // MARK: Initalization
    
    init(isBanUser: Bool, banDateString: String) {
        super.init(frame: .zero)
        
        self.setupConstraints()
        
        self.firstMessage = isBanUser ? Text.banUserDialogFirstMessage : Text.resignDialogFirstMessage
        self.secondMessage = Text.dialogSecondLeftMessage + banDateString + Text.dialogSecondRightMessage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private Func
    
    private func setupConstraints() {
        
        self.addSubview(self.firstDotLabel)
        self.firstDotLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        self.addSubview(self.firstMessageLabel)
        self.firstMessageLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.equalTo(self.firstDotLabel.snp.trailing).offset(4)
        }
        
        self.addSubview(self.secondDotLabel)
        self.secondDotLabel.snp.makeConstraints {
            $0.top.equalTo(self.firstMessageLabel.snp.bottom)
            $0.leading.equalToSuperview()
        }
        
        self.addSubview(self.secondMessageLabel)
        self.secondMessageLabel.snp.makeConstraints {
            $0.top.equalTo(self.firstMessageLabel.snp.bottom)
            $0.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(self.secondDotLabel.snp.trailing).offset(4)
        }
    }
}
