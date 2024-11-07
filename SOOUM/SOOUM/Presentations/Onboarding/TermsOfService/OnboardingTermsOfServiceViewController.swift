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

class OnboardingTermsOfServiceViewController: BaseNavigationViewController {
    
    enum TermsOfService: CaseIterable {
        case termsOfService
        case locationService
        case privacyPolicy
    }
    
    private var agreementStatus: [TermsOfService: Bool] = [
        .termsOfService: false,
        .locationService: false,
        .privacyPolicy: false
    ]
    
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
    
    override func bind() {
        agreeAllButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                let allAgreed = object.agreementStatus.values.allSatisfy { $0 == true }
                object.updateAllAgreements(to: !allAgreed)
            }
            .disposed(by: disposeBag)
    }
    
    /// 선택 상태 전부 업데이트
    private func updateAllAgreements(to isAgreed: Bool) {
        TermsOfService.allCases.forEach { agreementStatus[$0] = isAgreed }
        
        updateAgreeAllButtonState()
        
        termOfServiceTableView.reloadData()
    }
    
    private func updateAgreeAllButtonState() {
        let allAgreed = agreementStatus.values.allSatisfy { $0 == true }
        agreeAllButtonView.updateState(isOn: allAgreed)
    }
}

extension OnboardingTermsOfServiceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = termOfServiceTableView.dequeueReusableCell(
            withIdentifier: String(describing: OnboardingTermsOfServiceTableViewCell.self),
            for: indexPath
        )
        as! OnboardingTermsOfServiceTableViewCell
        
        return cell
    }
}
