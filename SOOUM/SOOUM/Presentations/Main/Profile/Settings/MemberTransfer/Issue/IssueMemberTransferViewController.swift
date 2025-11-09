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
        static let navigationTitle: String = "다른 기기에서 로그인하기"
        static let transferIssueTitle: String = "다른 기기로 계정을 옮길 수 있는 코드를 드릴게요"
        static let transferIssueGuideMessage: String = "코드는 1시간 동안 유효해요"
        static let transferReIssueButtonTitle: String = "코드 재발급하기"
    }
    
    
    // MARK: Views
    
    private let transferIssueTitleLabel = UILabel().then {
        $0.text = Text.transferIssueTitle
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.head2.withAlignment(.left)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    private let transferCodeLabel = UILabel().then {
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.subtitle1
    }
    
    private let transferIssueGuideMessageLabel = UILabel().then {
        $0.text = Text.transferIssueGuideMessage
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    
    private let transferExpireLabel = UILabel().then {
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.body2
    }
    
    private let updateTransferCodeButton = SOMButton().then {
        $0.title = Text.transferReIssueButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.white
        
        $0.backgroundColor = .som.v2.black
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    
    // MARK: Variables
    
    private var serialTimer: Disposable?
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.transferIssueTitleLabel)
        self.transferIssueTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        let transferCodeBackgroundView = UIView().then {
            $0.backgroundColor = .som.v2.gray100
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
        }
        
        self.view.addSubview(transferCodeBackgroundView)
        transferCodeBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.transferIssueTitleLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(54)
        }
        
        transferCodeBackgroundView.addSubview(self.transferCodeLabel)
        self.transferCodeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        
        transferCodeBackgroundView.addSubview(self.transferExpireLabel)
        self.transferExpireLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(self.transferCodeLabel.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        self.view.addSubview(self.updateTransferCodeButton)
        self.updateTransferCodeButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
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
            .subscribe(with: self.loadingIndicatorView) { loadingIndicatorView, isLoading in
                if isLoading {
                    loadingIndicatorView.startAnimating()
                } else {
                    loadingIndicatorView.stopAnimating()
                }
            }
            .disposed(by: self.disposeBag)
        
        let trnsferCodeInfo = reactor.state.map(\.trnsferCodeInfo).filterNil().distinctUntilChanged().share()
        trnsferCodeInfo
            .map(\.code)
            .bind(to: self.transferCodeLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        trnsferCodeInfo
            .map(\.expiredAt)
            .subscribe(with: self) { object, expiredAt in
                object.subscribePungTime(expiredAt)
            }
            .disposed(by: self.disposeBag)
        
        // TODO: 임시, 현재 복사 허용 X
        // self.transferCodeLabel.rx.tapGesture()
        //     .when(.recognized)
        //     .withLatestFrom(transferCode)
        //     .filter { $0.isEmpty == false }
        //     .subscribe(with: self) { object, transferCode in
        //
        //         // 계정 이관 코드 클립보드에 저장
        //         UIPasteboard.general.string = transferCode
        //         // Toast 표시, offset == 코드 재발급하기 버튼 height + margin
        //         self.showToast(message: Text.toastMessage, offset: 12 + 48 + 8)
        //     }
        //     .disposed(by: self.disposeBag)
    }
    
    
    // MARK: Private func
    
    private func subscribePungTime(_ pungTime: Date?) {
        self.serialTimer?.dispose()
        self.serialTimer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .startWith((self, 0))
            .map { object, _ in
                guard let pungTime = pungTime else {
                    object.serialTimer?.dispose()
                    return "00:00"
                }
                
                let currentDate = Date()
                let remainingTime = currentDate.infoReadableTimeTakenFromThisForPungToHoursAndMinutes(to: pungTime)
                if remainingTime == "00 : 00" {
                    object.serialTimer?.dispose()
                    object.transferExpireLabel.text = remainingTime
                }
                
                return remainingTime
            }
            .bind(to: self.transferExpireLabel.rx.text)
    }
}
