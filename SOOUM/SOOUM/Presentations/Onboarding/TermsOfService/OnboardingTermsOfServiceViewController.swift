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
    

    
//    private var agreementStatus = BehaviorRelay<[TermsOfService: Bool]>(
//        value: [
//            .termsOfService: false,
//            .locationService: false,
//            .privacyPolicy: false
//        ]
//    )
    

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
        
//        agreeAllButtonView.rx.tapGesture()
//            .when(.recognized)
//            .subscribe(with: self) { object, _ in
//                object.updateAllAgreements(to: !self.allAgreed)
//            }
//            .disposed(by: disposeBag)
        
//        agreementStatus
//            .subscribe(with: self) { object, state in
//                self.updateAgreeAllButtonState()
//                self.nextButtonView.updateState(state: self.allAgreed)
//            }
//            .disposed(by: disposeBag)
        
        nextButtonView.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.signUp }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
//        reactor.state.map(\.shoulNavigate)
//            .subscribe(with: self) { object, result in
//                if self.allAgreed {
//                    let nicknameSettingVC = OnboardingNicknameSettingViewController()
//                    let reactor = OnboardingNicknameSettingViewReactor()
//                    nicknameSettingVC.reactor = reactor
//                    self.navigationController?.pushViewController(nicknameSettingVC, animated: true)
//                }
//            }
//            .disposed(by: disposeBag)
        reactor.state.map { $0.isAgreedStats }
            .distinctUntilChanged()
            .subscribe(with: self) { object, statsDict in
                object.termOfServiceTableView.reloadData()
            }
            .disposed(by: self.disposeBag)
    }
    
    /// 선택 상태 전부 업데이트
//    private func updateAllAgreements(to isAgreed: Bool) {
//
//        let newStatus: [TermsOfService: Bool] = [
//            .termsOfService: isAgreed,
//            .locationService: isAgreed,
//            .privacyPolicy: isAgreed
//        ]
//        agreementStatus.accept(newStatus)
//        updateAgreeAllButtonState()
//    }
    /// 전체 동의 버튼 업데이트
//    private func updateAgreeAllButtonState() {
//        agreeAllButtonView.updateState(isOn: allAgreed)
//    }
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
        
        cell.setData(
            state: reactor.currentState.isAgreedStats[TermsOfService.allCases[indexPath.row]] ?? false,
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
//        
//        let term = TermsOfService.allCases[indexPath.row]
//        var newState = agreementStatus.value
//        newState[term]?.toggle()
//        agreementStatus.accept(newState)
    }
}
