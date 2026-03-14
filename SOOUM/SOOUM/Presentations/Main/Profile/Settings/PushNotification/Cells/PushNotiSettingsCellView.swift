//
//  PushNotiSettingsCellView.swift
//  SOOUM
//
//  Created by 오현식 on 3/7/26.
//

import UIKit

import SnapKit
import Then

final class PushNotiSettingsCellView: UIView {
    
    // MARK: Views
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.body1.withAlignment(.left)
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption3.withAlignment(.left)
    }
    
    let toggleBackgroundButton = UIButton()
    
    let toggleSwitch = UISwitch().then {
        $0.isOn = false
        $0.onTintColor = .som.v2.pMain
        $0.tintColor = .som.v2.gray200
        $0.thumbTintColor = .som.v2.white
        
        if let thumb = $0.subviews.first?.subviews.last?.subviews.last {
            thumb.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }
    }
    
    
    // MARK: Variables
    
    private var title: String? {
        set {
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text
        }
    }
    
    private var message: String? {
        set {
            self.messageLabel.text = newValue
            self.messageLabel.isHidden = newValue == nil
        }
        get {
            return self.messageLabel.text
        }
    }
    
    
    // MARK: Initialize
    
    convenience init(title: String, message: String? = nil) {
        self.init(frame: .zero)
        
        self.title = title
        self.message = message
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(48)
        }
        
        let container = UIStackView(arrangedSubviews: [self.titleLabel, self.messageLabel]).then {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.distribution = .equalSpacing
            $0.spacing = 0
        }
        self.addSubview(container)
        container.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        self.addSubview(self.toggleSwitch)
        self.toggleSwitch.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(container.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.addSubview(self.toggleBackgroundButton)
        self.toggleBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(self.toggleSwitch.snp.edges)
        }
    }
}
