//
//  SOMMessageBubbleView.swift
//  SOOUM
//
//  Created by 오현식 on 11/30/25.
//

import UIKit

import SnapKit
import Then

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
    
    
    // MARK: Initialize
    
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
    }
}
