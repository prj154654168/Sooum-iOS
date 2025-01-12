//
//  SettingTextCellView.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then


class SettingTextCellView: UIView {
    
    enum ButtonStyle {
        case arrow
        case toggle
    }
    
    private let titleLabel = UILabel().then {
        $0.typography = .som.body2WithBold
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.next)))
        $0.tintColor = .som.gray400
    }
    
    let toggleSwitch = UISwitch().then {
        $0.isOn = false
        $0.onTintColor = .som.p300
        $0.thumbTintColor = .som.white
        
        $0.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    let backgroundButton = UIButton()
    
    var buttonStyle: ButtonStyle?
    
    convenience init(
        buttonStyle: ButtonStyle = .arrow,
        title: String,
        titleColor: UIColor = .som.gray500
    ) {
        self.init(frame: .zero)
        
        self.buttonStyle = buttonStyle
        self.titleLabel.text = title
        self.titleLabel.textColor = titleColor
        
        self.setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(46)
        }
        
        switch self.buttonStyle {
        case .toggle:
            
            self.addSubview(self.titleLabel)
            self.titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(13)
                $0.bottom.equalToSuperview().offset(-13)
                $0.leading.equalToSuperview().offset(20)
            }
            
            self.addSubview(self.toggleSwitch)
            self.toggleSwitch.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().offset(-20)
            }
            
            self.addSubview(self.backgroundButton)
            self.bringSubviewToFront(self.backgroundButton)
            self.backgroundButton.snp.makeConstraints {
                $0.edges.equalTo(self.toggleSwitch)
            }
        default:
            
            let backgroundView = UIView()
            self.addSubview(backgroundView)
            backgroundView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(7)
                $0.bottom.equalToSuperview().offset(-7)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
            }
            
            backgroundView.addSubview(self.titleLabel)
            self.titleLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview()
            }
            
            backgroundView.addSubview(self.arrowImageView)
            self.arrowImageView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.size.equalTo(24)
            }
            
            self.addSubview(self.backgroundButton)
            self.bringSubviewToFront(self.backgroundButton)
            self.backgroundButton.snp.makeConstraints {
                $0.edges.equalTo(backgroundView)
            }
        }
    }
}
