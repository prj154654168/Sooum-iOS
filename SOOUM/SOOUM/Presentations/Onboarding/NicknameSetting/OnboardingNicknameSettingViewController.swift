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

class OnboardingNicknameSettingViewController: BaseNavigationViewController, View {
    
    private let maxCount = 8

    private let guideLabelView = OnboardingGuideLabelView().then {
        $0.titleLabel.text = "반가워요!\n당신을 어떻게 부르면 될까요?"
        $0.descLabel.text = "닉네임은 추후 변경이 가능해요"
    }
    
    private let nicknameTextField = OnboardingNicknameTextFieldView().then {
        $0.textField.text = "부끄러운 하마"
    }
    
    private let errorLogStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
        
        let imageView = UIImageView().then {
            $0.image = .error
            $0.contentMode = .scaleAspectFit
        }
        $0.addArrangedSubviews(imageView)
        $0.isHidden = true
    }
    
    private let errorLogLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 14,
                weight: .regular
            ),
            lineHeight: 19.6,
            letterSpacing: 0
        )
        // TODO: - 색 수정 필요
        $0.textColor = .red
        $0.text = "한 글자 이상 입력해주세요"
    }
    
    private let nicknameCountLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 14,
                weight: .regular
            ),
            lineHeight: 19.6,
            letterSpacing: 0
        )
        // TODO: - 색 수정 필요
        $0.textColor = .som.gray02
        $0.text = "1/8"
    }
    
    private let nextButtonView = PrimaryButtonView()
    
    // Reactor를 연결하고, 액션과 상태를 바인딩합니다.
    func bind(reactor: OnboardingNicknameSettingViewReactor) {
        
        nicknameTextField.textField.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] str in
                guard let self = self else { return }
                self.nicknameCountLabel.text = "\(str.count)/\(self.maxCount)"
            })
            .disposed(by: disposeBag)
        
        nicknameTextField.textField.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { Reactor.Action.textChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nicknameTextField.clearButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                object.nicknameCountLabel.text = "0/\(object.maxCount)"
                object.nicknameTextField.textField.text?.removeAll()
                object.reactor?.action.onNext(.textChanged(""))
            }
            .disposed(by: disposeBag)
        
        nextButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                let profileImageVC = ProfileImageSettingViewController()
                let profileImageReactor = ProfileImageSettingViewReactor(nickname: self.nicknameTextField.textField.text!)
                profileImageVC.reactor = profileImageReactor
                self.navigationController?.pushViewController(profileImageVC, animated: true)
            }
            .disposed(by: disposeBag)

        // MARK: - State Binding
        // 닉네임 유효성 검사 결과에 따라 nextButton의 활성화 상태 업데이트
        reactor.state
            .map { $0.isNicknameValid ?? OnboardingNicknameSettingViewReactor.NicknameState.invalid }
            .subscribe(with: self, onNext: { object, isValid in
                object.nextButtonView.updateState(state: isValid == .vaild)
                object.errorLogStackView.isHidden = isValid == .vaild
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorMessage }
            .subscribe(onNext: { [weak self] errorMessage in
                if let message = errorMessage {
                    self?.showErrorAlert(message)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Setup
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
        
        view.addSubview(errorLogStackView)
        errorLogStackView.addArrangedSubview(errorLogLabel)
        errorLogStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(10)
        }
        
        view.addSubview(nicknameCountLabel)
        nicknameCountLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(12)
        }
        
        view.addSubview(nextButtonView)
        nextButtonView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-13)
        }
    }
    
    // 키보드 상태 업데이트에 따른 버튼 위치 조정
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
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
