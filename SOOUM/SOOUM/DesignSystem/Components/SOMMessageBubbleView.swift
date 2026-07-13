//
//  SOMMessageBubbleView.swift
//  SOOUM
//
//  Created by 오현식 on 11/30/25.
//

import UIKit

import SnapKit
import Then
import RxCocoa

class SOMMessageBubbleView: UIView {
    
    
    // MARK: Views
    
    private let messageBackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.black
        $0.layer.cornerRadius = 26 * 0.5
    }
    
    private let messageTailView = UIImageView().then {
        $0.image = .init(.image(.v2(.message_tail)))
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .som.v2.white
        $0.typography = .som.v2.caption1
    }
    
    private let deleteButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.delete))))
        $0.foregroundColor = .som.v2.white
    }
    
    
    // MARK: Variables
    
    var message: String? {
        set {
            self.messageLabel.text = newValue
            self.messageLabel.typography = .som.v2.caption1
        }
        get {
            return self.messageLabel.text
        }
    }
    
    let deleteButtonDidTap = PublishRelay<Void>()
    
    private var isDeletable: Bool = false
    
    
    // MARK: Initialize
    
    init(isDeletable: Bool = false) {
        super.init(frame: .zero)
        
        self.isDeletable = isDeletable
        if isDeletable == false { self.isUserInteractionEnabled = false }
        self.setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.messageBackgroundView)
        self.messageBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(26)
        }
        
        self.addSubview(self.messageTailView)
        self.messageTailView.snp.makeConstraints {
            $0.top.equalTo(self.messageBackgroundView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(6)
            $0.height.equalTo(3)
        }
        
        self.messageBackgroundView.addSubview(self.messageLabel)
        self.messageLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        if isDeletable {
            self.messageBackgroundView.addSubview(self.deleteButton)
            self.deleteButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.greaterThanOrEqualTo(self.messageLabel.snp.trailing).offset(2)
                $0.trailing.equalToSuperview().offset(-8)
                $0.size.equalTo(16)
            }
            self.deleteButton.addTarget(
                self,
                action: #selector(self.didTapDeleteButton),
                for: .touchUpInside
            )
        }
    }
    
    @objc
    private func didTapDeleteButton() {
        self.deleteButtonDidTap.accept(())
    }
}
