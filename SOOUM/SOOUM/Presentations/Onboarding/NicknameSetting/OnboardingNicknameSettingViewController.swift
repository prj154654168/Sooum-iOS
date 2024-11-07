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


// MARK: - OnboardingNicknameTextFieldView
class OnboardingNicknameTextFieldView: UIView {
    /// 닉네임 입력 텍스트 필드
    let textField = UITextField().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 15,
                weight: .regular
            ),
            lineHeight: 24,
            letterSpacing: 0
        )
        $0.placeholder = "닉네임을 입력해주세요"
        $0.textColor = .som.black
    }
    
    /// 클리어버튼 터치 영역 잡는 뷰
    let clearButtonView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let clearImageView = UIImageView().then {
        $0.image = .cancelOutlined
        $0.tintColor = .som.black
    }
    
    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 12
        self.backgroundColor = .som.gray04
        initConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        self.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        
        self.addSubviews(textField)
        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }
        
        self.addSubviews(clearButtonView)
        clearButtonView.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
        }
        
        clearButtonView.addSubviews(clearImageView)
        clearImageView.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.center.equalToSuperview()
        }
    }
}

// MARK: - OnboardingNicknameSettingViewController
class OnboardingNicknameSettingViewController: BaseNavigationViewController {
    
    let guideLabelView = OnboardingGuideLabelView().then {
        $0.titleLabel.text = "반가워요!\n당신을 어떻게 부르면 될까요?"
        $0.descLabel.text = "닉네임은 추후 변경이 가능해요"
    }
    
    let nicknameTextField = OnboardingNicknameTextFieldView()
        
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
    }
}
