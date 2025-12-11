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
        
        static let privacyPolicyURLString: String = "https://adjoining-guanaco-d0a.notion.site/26b2142ccaa38059a1dbf3e6b6b6b4e6?pvs=74"
        static let termsOfServiceURLString: String = "https://adjoining-guanaco-d0a.notion.site/26b2142ccaa38076b491df099cd7b559"
        static let termsOfLocationInfoURLString: String = "https://adjoining-guanaco-d0a.notion.site/26b2142ccaa380f1bfafe99f5f8a10f1?pvs=74"
    }
    
    private let scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.contentInsetAdjustmentBehavior = .never
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
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                if let url = URL(string: Text.privacyPolicyURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            .disposed(by: self.disposeBag)
        
        self.termsOfServiceCellView.rx.didSelect
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                if let url = URL(string: Text.termsOfServiceURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            .disposed(by: self.disposeBag)
        
        self.termsOfLocationInfoCellView.rx.didSelect
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                if let url = URL(string: Text.termsOfLocationInfoURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            .disposed(by: self.disposeBag)
    }
}
