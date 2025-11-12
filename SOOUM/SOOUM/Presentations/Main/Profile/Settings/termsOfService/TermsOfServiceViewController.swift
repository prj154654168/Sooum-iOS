//
//  TermsOfServiceViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift


class TermsOfServiceViewController: BaseNavigationViewController {
    
    enum Text {
        static let navigationTitle: String = "약관 및 개인정보 처리 동의"
        static let privacyPolicyTitle: String = "개인정보처리방침"
        static let termsOfServiceTitle: String = "서비스 이용약관"
        static let termsOfLocationInfoTitle: String = "위치정보 이용약관"
    }
    
    private let scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let privacyPolicyCellView = TermsOfServiceTextCellView(title: Text.privacyPolicyTitle)
    private let termsOfServiceCellView = TermsOfServiceTextCellView(title: Text.termsOfServiceTitle)
    private let termsOfLocationInfoCellView = TermsOfServiceTextCellView(title: Text.termsOfLocationInfoTitle)
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + padding
        return 34 + 8
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        
        self.view.backgroundColor = .som.white
        
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        let container = UIStackView(arrangedSubviews: [
            self.privacyPolicyCellView,
            self.termsOfServiceCellView,
            self.termsOfLocationInfoCellView
        ]).then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .equalSpacing
        }
        self.scrollView.addSubview(container)
        container.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    override func bind() {
        super.bind()
        
        self.privacyPolicyCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                if let url = URL(string: "https://mewing-space-6d3.notion.site/3f92380d536a4b569921d2809ed147ef?pvs=4") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            .disposed(by: self.disposeBag)
        
        self.termsOfServiceCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                if let url = URL(string: "https://mewing-space-6d3.notion.site/45d151f68ba74b23b24483ad8b2662b4?pvs=4") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            .disposed(by: self.disposeBag)
        
        self.termsOfLocationInfoCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                if let url = URL(string: "https://mewing-space-6d3.notion.site/44e378c9d11d45159859492434b6b128?pvs=4") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            .disposed(by: self.disposeBag)
    }
}
