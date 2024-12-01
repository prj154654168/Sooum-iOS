//
//  OnboardingTermsOfServiceViewController.swift
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

class OnboardingTermsOfServiceViewController: BaseNavigationViewController, View {
    
    let guideLabelView = OnboardingGuideLabelView().then {
        $0.titleLabel.text = "숨을 시작하기 위해서는\n약관 동의가 필요해요"
        $0.descLabel.isHidden = true
    }
    
    let agreeAllButtonView = TermsOfServiceAgreeButtonView()
    
    let nextButtonView = PrimaryButtonView()
    
    lazy var termOfServiceTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.register(
            OnboardingTermsOfServiceTableViewCell.self,
            forCellReuseIdentifier: String(describing: OnboardingTermsOfServiceTableViewCell.self)
        )
        
        $0.dataSource = self
        $0.delegate = self
    }
        
    override func setupConstraints() {
        view.addSubview(guideLabelView)
        guideLabelView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
        }
        
        view.addSubview(agreeAllButtonView)
        agreeAllButtonView.snp.makeConstraints {
            $0.top.equalTo(guideLabelView.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        view.addSubview(termOfServiceTableView)
        termOfServiceTableView.snp.makeConstraints {
            $0.top.equalTo(agreeAllButtonView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(nextButtonView)
        nextButtonView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-13)
        }
    }
    
    func bind(reactor: OnboardingTermsOfServiceViewReactor) {
        
        // 전체 동의 버튼 클릭
        agreeAllButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                reactor.action.onNext(.allAgree)
            }
            .disposed(by: disposeBag)
        
        nextButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self, onNext: { object, _ in
                if reactor.currentState.isAllAgreed {
                    reactor.action.onNext(.signUp)
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map(\.shoulNavigate)
            .filter { [weak self] shouldNavigate in
                shouldNavigate && ((self?.reactor?.currentState.isAllAgreed) != nil)
            }
            .subscribe(with: self) { object, _ in
                object.navigateToNicknameSetting()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map(\.isAllAgreed)
            .distinctUntilChanged()
            .subscribe(with: self) { object, state in
                object.agreeAllButtonView.updateState(isOn: state)
                object.nextButtonView.updateState(state: state)
            }
            .disposed(by: self.disposeBag)

        
        reactor.state
            .map(\.isTermsOfServiceAgreed)
            .distinctUntilChanged()
            .subscribe(with: self) { object, state in
                guard let cell = object.termOfServiceTableView.cellForRow(
                    at: TermsOfService.termsOfService.indexPath
                ) as? OnboardingTermsOfServiceTableViewCell else {
                    return
                }
                cell.updateState(isOn: state, animated: true)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map(\.isLocationAgreed)
            .distinctUntilChanged()
            .subscribe(with: self) { object, state in
                guard let cell = object.termOfServiceTableView.cellForRow(
                    at: TermsOfService.locationService.indexPath
                ) as? OnboardingTermsOfServiceTableViewCell else {
                    return
                }
                cell.updateState(isOn: state, animated: true)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map(\.isPrivacyPolicyAgreed)
            .distinctUntilChanged()
            .subscribe(with: self) { object, state in
                guard let cell = object.termOfServiceTableView.cellForRow(
                    at: TermsOfService.privacyPolicy.indexPath
                ) as? OnboardingTermsOfServiceTableViewCell else {
                    return
                }
                cell.updateState(isOn: state, animated: true)
            }
            .disposed(by: self.disposeBag)
    }
    
    private func navigateToNicknameSetting() {
        let nicknameSettingVC = OnboardingNicknameSettingViewController()
        nicknameSettingVC.reactor = OnboardingNicknameSettingViewReactor()
        navigationController?.pushViewController(nicknameSettingVC, animated: true)
    }

    /// 전체 동의 버튼 업데이트
    private func updateAgreeAllButtonState(isOn: Bool) {
        agreeAllButtonView.updateState(isOn: isOn)
    }
}

extension OnboardingTermsOfServiceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TermsOfService.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = termOfServiceTableView.dequeueReusableCell(
            withIdentifier: String(describing: OnboardingTermsOfServiceTableViewCell.self),
            for: indexPath
        )
        as! OnboardingTermsOfServiceTableViewCell

        guard let reactor = self.reactor else {
            return UITableViewCell()
        }
        
        let state: Bool
        switch TermsOfService.allCases[indexPath.row] {
        case .termsOfService:
            state = reactor.currentState.isTermsOfServiceAgreed
        case .locationService:
            state = reactor.currentState.isLocationAgreed
        case .privacyPolicy:
            state = reactor.currentState.isPrivacyPolicyAgreed
        }
        
        cell.setData(
            state: state,
            term: TermsOfService.allCases[indexPath.row]
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch TermsOfService.allCases[indexPath.row] {
        case .termsOfService:
            self.reactor?.action.onNext(.termsOfServiceAgree)
            
        case .locationService:
            self.reactor?.action.onNext(.locationAgree)

        case .privacyPolicy:
            self.reactor?.action.onNext(.privacyPolicyAgree)
        }
    }
}
