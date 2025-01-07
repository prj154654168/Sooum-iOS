//
//  IssueMemberTransferViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift


class IssueMemberTransferViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "계정 이관 코드 발급"
        static let topTransferIssueMessage: String = "계정을 다른 기기로 이관하기 위한"
        static let bottomTransferIssueMessage: String = "코드를 발급합니다"
        static let firstTransferIssueGuide: String = "발급된 코드는 24시간만 유효합니다"
        static let topSecondTransferIssueGuide: String = "코드가 유출되면 타인이 해당 계정을"
        static let bottomSecondTransferIssueGuide: String = "가져갈 수 있으니 주의하세요"
        static let transferReIssueButtonTitle: String = "코드 재발급하기"
        
        static let toastMessage: String = "코드가 복사되었습니다"
    }
    
    private let topTransferIssueMessageLabel = UILabel().then {
        $0.text = Text.topTransferIssueMessage
        $0.textColor = .som.gray800
        $0.typography = .som.body1WithBold
    }
    private let bottomTransferIssueMessageLabel = UILabel().then {
        $0.text = Text.bottomTransferIssueMessage
        $0.textColor = .som.gray800
        $0.typography = .som.body1WithBold
    }
    
    private let transferCodeLabel = UILabel().then {
        $0.textColor = .som.black
        $0.typography = .som.body1WithBold
    }
    
    private let firstTransferIssueGuideLabel = UILabel().then {
        $0.text = Text.firstTransferIssueGuide
        $0.textColor = .som.gray700
        $0.typography = .som.body1WithBold
    }
    
    private let topSecondTransferIssueGuideLabel = UILabel().then {
        $0.text = Text.topSecondTransferIssueGuide
        $0.textColor = .som.red
        $0.typography = .som.body3WithBold
    }
    private let bottomSecondTransferIssueGuideLabel = UILabel().then {
        $0.text = Text.bottomSecondTransferIssueGuide
        $0.textColor = .som.red
        $0.typography = .som.body3WithBold
    }
    
    private let updateTransferCodeButton = SOMButton().then {
        $0.title = Text.transferReIssueButtonTitle
        $0.typography = .som.body1WithBold
        $0.foregroundColor = .som.white
        
        $0.backgroundColor = .som.p300
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        let transferBackgroundView = UIView().then {
            $0.backgroundColor = .som.gray50
            $0.layer.cornerRadius = 22
            $0.clipsToBounds = true
        }
        self.view.addSubview(transferBackgroundView)
        transferBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(149)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        transferBackgroundView.addSubview(self.topTransferIssueMessageLabel)
        self.topTransferIssueMessageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(34)
            $0.centerX.equalToSuperview()
        }
        transferBackgroundView.addSubview(self.bottomTransferIssueMessageLabel)
        self.bottomTransferIssueMessageLabel.snp.makeConstraints {
            $0.top.equalTo(self.topTransferIssueMessageLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        let transferCodeBackgroundView = UIView().then {
            $0.backgroundColor = .som.white
            $0.layer.borderColor = UIColor.som.p300.cgColor
            $0.layer.borderWidth = 2
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
        transferBackgroundView.addSubview(transferCodeBackgroundView)
        transferCodeBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.bottomTransferIssueMessageLabel.snp.bottom).offset(32)
            $0.bottom.trailing.equalToSuperview().offset(-20)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(64)
        }
        
        transferCodeBackgroundView.addSubview(self.transferCodeLabel)
        self.transferCodeLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.view.addSubview(self.firstTransferIssueGuideLabel)
        self.firstTransferIssueGuideLabel.snp.makeConstraints {
            $0.top.equalTo(transferBackgroundView.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.topSecondTransferIssueGuideLabel)
        self.topSecondTransferIssueGuideLabel.snp.makeConstraints {
            $0.top.equalTo(self.firstTransferIssueGuideLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        self.view.addSubview(self.bottomSecondTransferIssueGuideLabel)
        self.bottomSecondTransferIssueGuideLabel.snp.makeConstraints {
            $0.top.equalTo(self.topSecondTransferIssueGuideLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.updateTransferCodeButton)
        self.updateTransferCodeButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: IssueMemberTransferViewReactor) {
        
        // Action
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.updateTransferCodeButton.rx.throttleTap(.seconds(1))
            .map { _ in Reactor.Action.updateTransferCode }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        let transferCode = reactor.state.map(\.trnsferCode).distinctUntilChanged().share()
        transferCode
            .bind(to: self.transferCodeLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        self.transferCodeLabel.rx.tapGesture()
            .when(.recognized)
            .withLatestFrom(transferCode)
            .filter { $0.isEmpty == false }
            .subscribe(with: self) { object, transferCode in
                
                // 계정 이관 코드 클립보드에 저장
                UIPasteboard.general.string = transferCode
                // Toast 표시, offset == 코드 재발급하기 버튼 height + margin
                self.showToast(message: Text.toastMessage, offset: 12 + 48 + 8)
            }
            .disposed(by: self.disposeBag)
    }
}
