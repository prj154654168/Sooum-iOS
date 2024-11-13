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
    
    enum TermsOfService: CaseIterable {
        case termsOfService
        case locationService
        case privacyPolicy
        
        var text: String {
            switch self {
            case .termsOfService:
                "[필수] 서비스 이용 약관"
            case .locationService:
                "[필수] 위치정보 이용 약관"
            case .privacyPolicy:
                "[필수] 개인정보 처리 방침"
            }
        }
    }
    
    private var agreementStatus = BehaviorRelay<[TermsOfService: Bool]>(
        value: [
            .termsOfService: false,
            .locationService: false,
            .privacyPolicy: false
        ]
    )
    
    var allAgreed: Bool {
        return agreementStatus.value.values.allSatisfy { $0 == true }
    }

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
        super.bind()
        
        agreeAllButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                object.updateAllAgreements(to: !self.allAgreed)
            }
            .disposed(by: disposeBag)
        
        agreementStatus
            .subscribe(with: self) { object, state in
                self.updateAgreeAllButtonState()
                self.nextButtonView.updateState(state: self.allAgreed)
            }
            .disposed(by: disposeBag)
        
        nextButtonView.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.signUp }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.shoulNavigate)
            .subscribe(with: self) { object, result in
                if self.allAgreed {
                    let nicknameSettingVC = OnboardingNicknameSettingViewController()
                    let reactor = OnboardingNicknameSettingViewReactor()
                    nicknameSettingVC.reactor = reactor
                    self.navigationController?.pushViewController(nicknameSettingVC, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    /// 선택 상태 전부 업데이트
    private func updateAllAgreements(to isAgreed: Bool) {
        print("\(type(of: self)) - \(#function) isAgreed", isAgreed)

        let newStatus: [TermsOfService: Bool] = [
            .termsOfService: isAgreed,
            .locationService: isAgreed,
            .privacyPolicy: isAgreed
        ]
        agreementStatus.accept(newStatus)
        updateAgreeAllButtonState()
    }
    /// 전체 동의 버튼 업데이트
    private func updateAgreeAllButtonState() {
        print("\(type(of: self)) - \(#function)")
        agreeAllButtonView.updateState(isOn: allAgreed)
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
        cell.setData(state: self.agreementStatus, term: TermsOfService.allCases[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let term = TermsOfService.allCases[indexPath.row]
        var newState = agreementStatus.value
        newState[term]?.toggle()
        agreementStatus.accept(newState)
    }
}
