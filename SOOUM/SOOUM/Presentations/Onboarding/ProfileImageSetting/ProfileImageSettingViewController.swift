//
//  ProfileImageSettingViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/6/24.
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
        $0.backgroundColor = .som.gray03
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

// MARK: - ProfileImageSettingViewController
class ProfileImageSettingViewController: BaseNavigationViewController {
    
    let guideLabelView = OnboardingGuideLabelView().then {
        $0.titleLabel.text = "당신을 표현하는 사진을\n프로필로 등록해볼까요?"
        $0.descLabel.text = "프로필 사진은 추후 변경이 가능해요"
    }
    
    let profileImageSettingView = OnboardingProfileImageSettingView()
        
    let okButton = PrimaryButtonView()
    
    let passButton = PrimaryButtonView()
    
    override func setupConstraints() {
        view.addSubview(guideLabelView)
        guideLabelView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
        }
        
        view.addSubview(profileImageSettingView)
        profileImageSettingView.snp.makeConstraints {
            $0.top.equalTo(guideLabelView.snp.bottom).offset(94)
            $0.centerX.equalToSuperview()
        }
                
        view.addSubviews(passButton)
        passButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        view.addSubview(okButton)
        okButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(passButton.snp.top).offset(-12)
        }
    }
}
