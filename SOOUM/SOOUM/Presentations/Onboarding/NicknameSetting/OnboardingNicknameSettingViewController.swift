//
//  OnboardingNicknameSettingViewController.swift
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

// MARK: - OnboardingNicknameSettingViewController
class OnboardingNicknameSettingViewController: BaseNavigationViewController, View {

    let guideLabelView = OnboardingGuideLabelView().then {
        $0.titleLabel.text = "반가워요!\n당신을 어떻게 부르면 될까요?"
        $0.descLabel.text = "닉네임은 추후 변경이 가능해요"
    }
    
    let nicknameTextField = OnboardingNicknameTextFieldView()
        
    let nextButtonView = PrimaryButtonView()
        
    override func setupConstraints() {
        view.addSubview(guideLabelView)
        guideLabelView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
        }
        
        view.addSubview(nicknameTextField)
        nicknameTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(guideLabelView.snp.bottom).offset(24)
        }
        
        view.addSubview(nextButtonView)
        nextButtonView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-13)
        }
    }
    
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
                
        UIView.animate(withDuration: 0.25) {
            self.nextButtonView.snp.updateConstraints {
                let offset = -height - 13
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(offset)
            }
        }
        self.view.layoutIfNeeded()
    }
}
