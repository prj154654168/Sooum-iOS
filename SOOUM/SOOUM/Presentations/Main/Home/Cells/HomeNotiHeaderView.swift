//
//  HomeNotiHeaderView.swift
//  SOOUM
//
//  Created by 오현식 on 1/28/26.
//

import UIKit

import SnapKit
import Then

import RxCocoa

final class HomeNotiHeaderView: UIView {
    
    
    // MARK: Views
    
    private lazy var shadowbackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.cornerRadius = 16
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(self.backgroundDidTapped(_:))
        )
        $0.addGestureRecognizer(tapGesture)
    }
    
    let deleteButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.delete_full))))
        $0.foregroundColor = .som.v2.gray300
    }
    
    private let iconView = UIImageView()
    
    private let messageLabel = UILabel().then {
        $0.textColor = .som.v2.gray600
        $0.typography = .som.v2.caption1.withAlignment(.left)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    
    // MARK: Variables
    
    private(set) var model: NoticeInfo?
    
    
    // MARK: Variables + Rx
    
    let backgroundDidTapped = PublishRelay<String?>()
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.shadowbackgroundView.setShadow(
            radius: 6,
            color: UIColor(hex: "#ABBED11A").withAlphaComponent(0.1),
            blur: 16,
            offset: .init(width: 0, height: 6)
        )
    }
    
    
    // MARK: Objc func
    
    @objc
    private func backgroundDidTapped(_ recognizer: UITapGestureRecognizer) {
        self.backgroundDidTapped.accept(self.model?.url)
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.clipsToBounds = true
        
        self.addSubview(self.shadowbackgroundView)
        self.shadowbackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.shadowbackgroundView.addSubview(self.iconView)
        self.iconView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.size.equalTo(24)
        }
        
        self.shadowbackgroundView.addSubview(self.messageLabel)
        self.messageLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.iconView.snp.trailing).offset(8)
        }
        
        self.shadowbackgroundView.addSubview(self.deleteButton)
        self.deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.messageLabel.snp.trailing).offset(14)
            $0.trailing.equalToSuperview().offset(-14)
            $0.size.equalTo(20)
        }
    }
    
    
    // MARK: Public func
    
    func setModel(_ model: NoticeInfo) {
        
        self.model = model
        
        self.iconView.image = model.noticeType.image
        self.iconView.tintColor = model.noticeType.tintColor
        
        self.messageLabel.text = model.message
        self.messageLabel.typography = .som.v2.caption1.withAlignment(.left)
    }
}
