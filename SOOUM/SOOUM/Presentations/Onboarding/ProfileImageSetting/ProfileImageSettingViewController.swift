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

class ProfileImageSettingViewController: BaseNavigationViewController {
    
    let guideLabelView = OnboardingGuideLabelView().then {
        $0.titleLabel.text = "당신을 표현하는 사진을\n프로필로 등록해볼까요?"
        $0.descLabel.text = "프로필 사진은 추후 변경이 가능해요"
    }
    
    let profileImageSettingView = OnboardingProfileImageSettingView()
        
    let okButton = PrimaryButtonView()
    
    let passButton = PrimaryButtonView()
    
    func bind(reactor: ProfileImageSettingViewReactor) {
        
    }

    
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
