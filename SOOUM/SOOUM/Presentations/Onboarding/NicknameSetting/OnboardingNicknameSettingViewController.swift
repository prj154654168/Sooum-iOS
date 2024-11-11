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

    let guideLabelView = OnboardingGuideLabelView().then {
        $0.titleLabel.text = "반가워요!\n당신을 어떻게 부르면 될까요?"
        $0.descLabel.text = "닉네임은 추후 변경이 가능해요"
    }
    
    let nicknameTextField = OnboardingNicknameTextFieldView()
    let nextButtonView = PrimaryButtonView()
    
    // Reactor를 연결하고, 액션과 상태를 바인딩합니다.
    func bind(reactor: OnboardingNicknameSettingViewReactor) {
        
        // MARK: - Action Binding
        // nicknameTextField의 텍스트가 변경될 때마다 Reactor에 전달
        nicknameTextField.textField.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // 디바운스 적용
            .compactMap { str in
                return str.isEmpty ? nil : str
            }
            .distinctUntilChanged() // 중복된 텍스트 입력 방지
            .map {
                print("Reactor.Action.textChanged($0)", $0)
                return Reactor.Action.textChanged($0)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // MARK: - State Binding
        // 닉네임 유효성 검사 결과에 따라 nextButton의 활성화 상태 업데이트
        reactor.state
            .map { $0.isNicknameValid ?? false }
            .subscribe(with: self, onNext: { object, isValid in
                print("$0.isNicknameValid", isValid)
                object.nextButtonView.updateState(state: isValid)
            })
            .disposed(by: disposeBag)
        
        // 에러 메시지 표시
        reactor.state
            .map { $0.errorMessage }
            .subscribe(onNext: { [weak self] errorMessage in
                print("$0.errorMessage", errorMessage)
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
