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
import RxSwift


class IssueMemberTransferViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "계정 이관 코드 발급"
        static let transferIssueMessage: String = "계정을 다른 기기로 이관하기 위한\n코드를 발급합니다"
        static let firstTransferIssueGuide: String = "발급된 코드는 24시간만 유효합니다"
        static let secondTransferIssueGuide: String = "코드가 유출되면 타인이 해당 계정을\n가져갈 수 있으니 주의하세요 "
        static let transferReIssueButtonTitle: String = "코드 재발급하기"
    }
    
    private let transferIssueMessageLabel = UILabel().then {
        $0.text = Text.transferIssueMessage
        $0.textColor = .som.gray800
        $0.typography = .som.body1WithBold
        $0.numberOfLines = 0
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
    
    private let secondTransferIssueGuideLabel = UILabel().then {
        $0.text = Text.secondTransferIssueGuide
        $0.textColor = .som.red
        $0.typography = .som.body3WithBold
        $0.numberOfLines = 0
    }
    
    private let updateTransferCodeButton = UIButton().then {
        let typography = Typography.som.body1WithBold
        var attributes = typography.attributes
        attributes.updateValue(typography.font, forKey: .font)
        attributes.updateValue(UIColor.som.white, forKey: .foregroundColor)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init(
            Text.transferReIssueButtonTitle,
            attributes: AttributeContainer(attributes)
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            AttributeContainer(attributes)
        }
        $0.configuration = config
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
        
        transferBackgroundView.addSubview(self.transferIssueMessageLabel)
        self.transferIssueMessageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(34)
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
            $0.top.equalTo(self.transferIssueMessageLabel.snp.bottom).offset(32)
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
        
        self.view.addSubview(self.secondTransferIssueGuideLabel)
        self.secondTransferIssueGuideLabel.snp.makeConstraints {
            $0.top.equalTo(self.firstTransferIssueGuideLabel.snp.bottom).offset(8)
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
        
        self.updateTransferCodeButton.rx.throttleTap(.seconds(3))
            .map { _ in Reactor.Action.updateTransferCode }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.trnsferCode)
            .distinctUntilChanged()
            .bind(to: self.transferCodeLabel.rx.text)
            .disposed(by: self.disposeBag)
    }
}
