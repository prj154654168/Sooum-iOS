//
//  OnboardingViewController.swift
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

class OnboardingViewController: BaseNavigationViewController {
    
    let backgroundImageView = UIImageView().then {
        $0.image = .onboardingBackground
        $0.contentMode = .scaleAspectFill
    }
    
    let guideLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 22,
                weight: .semibold
            ),
            lineHeight: 35.2,
            letterSpacing: 0
        )
        $0.textColor = .som.primary
        $0.numberOfLines = 0
        $0.text = "당신의 소중한 이야기를\n익명의 친구들에게 들려주세요"
    }
    
    let startButtonLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 16,
                weight: .semibold
            ),
            lineHeight: 35.2,
            letterSpacing: 0
        )
        $0.text = "숨 시작하기"
        $0.layer.cornerRadius = 12
        $0.textAlignment = .center
        $0.backgroundColor = .som.primary
        $0.textColor = .som.white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    let oldUserButtonLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 14,
                weight: .regular
            ), lineHeight: 20
        )
        $0.text = "기존 계정이 있으신가요?"
        $0.textColor = .som.gray01
        $0.layer.cornerRadius = 12
        $0.textAlignment = .center
        $0.backgroundColor = .clear
    }
    
    override func setupNaviBar() {
        super.setupNaviBar()
        self.isNavigationBarHidden = true
    }
    
    override func bind() {
        super.bind()
        startButtonLabel.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                let termsOfServiceVC = OnboardingTermsOfServiceViewController()
                self.navigationController?.pushViewController(termsOfServiceVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupConstraints() {
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(guideLabel)
        guideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        view.addSubview(startButtonLabel)
        startButtonLabel.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(guideLabel.snp.bottom).offset(84)
        }
        
        view.addSubview(oldUserButtonLabel)
        oldUserButtonLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(42)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(startButtonLabel.snp.bottom).offset(10)
        }
    }
}