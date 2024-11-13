//
//  OnboardingProfileImageSettingView.swift
//  SOOUM
//
//  Created by JDeoks on 11/7/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

// MARK: - OnboardingProfileImageSettingView
class OnboardingProfileImageSettingView: UIView {
    
    let imageView = UIImageView().then {
        $0.image = .sooumLogo
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 64
    }
    
    let changeImageButtonView = UIView().then {
        $0.backgroundColor = .som.gray400
        $0.layer.cornerRadius = 16
    }
    
    let changeImageView = UIImageView().then {
        $0.image = .cameraOutlined
    }
    
    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initConstraint()
        self.backgroundColor = .clear
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        self.snp.makeConstraints {
            $0.size.equalTo(128)
        }
        
        self.addSubviews(imageView)
        imageView.snp.makeConstraints {
            $0.size.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        self.addSubviews(changeImageButtonView)
        changeImageButtonView.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.trailing.equalToSuperview().offset(-4)
            $0.bottom.equalToSuperview().offset(-4)
        }
        
        changeImageButtonView.addSubviews(changeImageView)
        changeImageView.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.center.equalToSuperview()
        }
    }
}
