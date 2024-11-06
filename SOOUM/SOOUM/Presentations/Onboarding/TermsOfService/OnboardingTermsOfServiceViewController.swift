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
    
    let guideLabelView = OnboardingGuideLabelView().then {
        $0.titleLabel.text = "숨을 시작하기 위해서는\n약관 동의가 필요해요"
        $0.descLabel.isHidden = true
    }
    
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
        
        view.addSubview(termOfServiceTableView)
        termOfServiceTableView.snp.makeConstraints {
            $0.top.equalTo(guideLabelView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension OnboardingTermsOfServiceViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = termOfServiceTableView.dequeueReusableCell(
            withIdentifier: String(describing: OnboardingTermsOfServiceTableViewCell.self),
            for: indexPath)
        as! OnboardingTermsOfServiceTableViewCell
        
        return cell
    }
}
