//
//  ResignViewController.swift
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


class ResignViewController: BaseNavigationViewController, View {

    enum Text {
        static let navigationTitle: String = "계정 탈퇴"
        static let firstResignTitle: String = "탈퇴하기 전"
        static let secondResignTitle: String = "몇가지 안내가 있어요"
        static let dot: String = "•"
        static let firstResignGuide: String = "지금까지 작성한 카드와 정보들이 모두 삭제될 예정이에요"
        static let secondResignGuide: String = "재가입은 탈퇴 일자를 기준으로 일주일이후 가능해요"
        static let secondResignGuideWithBanFrom: String = "계정이 정지 상태 이므로, 정지 해지 날짜인"
        static let secondResignGuideWithBanTo: String = "까지 재가입이 불가능해요"
        static let checkResignGuide: String = "위 안내사항을 모두 확인했습니다"
        static let resignButtonTitle: String = "탈퇴하기"
        
        static let dialogTitle: String = "계정이 이전된 기기입니다"
        static let dialogMessge: String = "탈퇴 요청은 계정 이관코드를 입력한 기기에서 진행해주세요"
        static let confirmActionTitle: String = "확인"
    }
    
    private let firstResignTitleLabel = UILabel().then {
        $0.text = Text.firstResignTitle
        $0.textColor = .som.gray800
        $0.typography = .som.head2WithBold
    }
    
    private let secondResignTitleLabel = UILabel().then {
        $0.text = Text.secondResignTitle
        $0.textColor = .som.gray800
        $0.typography = .som.head2WithBold
    }
    
    private let firstDotLabel = UILabel().then {
        $0.text = Text.dot
        $0.textColor = .som.gray600
        $0.typography = .som.body2WithRegular
    }
    private let firstResignGuideLabel = UILabel().then {
        $0.text = Text.firstResignGuide
        $0.textColor = .som.gray600
        $0.typography = .som.body2WithRegular.withAlignment(.left)
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
        $0.numberOfLines = 0
    }
    
    private let secondDotLabel = UILabel().then {
        $0.text = Text.dot
        $0.textColor = .som.gray600
        $0.typography = .som.body2WithRegular
    }
    private let secondResignGuideLabel = UILabel().then {
        $0.text = Text.secondResignGuide
        $0.textColor = .som.gray600
        $0.typography = .som.body2WithRegular.withAlignment(.left)
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
        $0.numberOfLines = 0
    }
    
    private let checkBoxButton = UIButton()
    private let checkBox = UIImageView().then {
        $0.image = .init(.icon(.outlined(.checkBox)))
        $0.tintColor = .som.gray500
    }
    private let checkResignGuideLabel = UILabel().then {
        $0.text = Text.checkResignGuide
        $0.textColor = .som.gray600
        $0.typography = .som.body1WithRegular
    }
    
    private let resignButton = SOMButton().then {
        $0.title = Text.resignButtonTitle
        $0.typography = .som.body1WithBold
        $0.foregroundColor = .som.gray600
        
        $0.backgroundColor = .som.gray300
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        
        $0.isEnabled = false
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.firstResignTitleLabel)
        self.firstResignTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(137)
            $0.centerX.equalToSuperview()
        }
        self.view.addSubview(self.secondResignTitleLabel)
        self.secondResignTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.firstResignTitleLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        let resignGuideBackgroundView = UIView().then {
            $0.backgroundColor = .som.gray50
            $0.layer.cornerRadius = 13
            $0.clipsToBounds = true
        }
        self.view.addSubview(resignGuideBackgroundView)
        resignGuideBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.secondResignTitleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        resignGuideBackgroundView.addSubview(self.firstDotLabel)
        self.firstDotLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(19)
        }
        resignGuideBackgroundView.addSubview(self.firstResignGuideLabel)
        self.firstResignGuideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalTo(self.firstDotLabel.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().offset(-19)
        }
        
        resignGuideBackgroundView.addSubview(self.secondDotLabel)
        self.secondDotLabel.snp.makeConstraints {
            $0.top.equalTo(self.firstResignGuideLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(19)
        }
        resignGuideBackgroundView.addSubview(self.secondResignGuideLabel)
        self.secondResignGuideLabel.snp.makeConstraints {
            $0.top.equalTo(self.firstResignGuideLabel.snp.bottom)
            $0.bottom.equalToSuperview().offset(-20)
            $0.leading.equalTo(self.secondDotLabel.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().offset(-19)
        }
        
        self.view.addSubview(self.checkBox)
        self.checkBox.snp.makeConstraints {
            $0.top.equalTo(resignGuideBackgroundView.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(24)
            $0.size.equalTo(24)
        }
        self.view.addSubview(self.checkResignGuideLabel)
        self.checkResignGuideLabel.snp.makeConstraints {
            $0.top.equalTo(resignGuideBackgroundView.snp.bottom).offset(28)
            $0.leading.equalTo(self.checkBox.snp.trailing).offset(11)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        self.view.addSubview(self.checkBoxButton)
        self.checkBoxButton.snp.makeConstraints {
            $0.top.equalTo(self.checkBox.snp.top)
            $0.leading.equalTo(self.checkBox.snp.leading)
            $0.trailing.equalTo(self.checkResignGuideLabel.snp.trailing)
            $0.height.equalTo(24)
        }
        
        self.view.addSubview(self.resignButton)
        self.resignButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: ResignViewReactor) {
        
        if let banEndAt = reactor.banEndAt {
            self.secondResignGuideLabel.text = "\(Text.secondResignGuideWithBanFrom) \(banEndAt.banEndFormatted)\(Text.secondResignGuideWithBanTo)"
        }
        
        // Action
        self.checkBoxButton.rx.throttleTap(.seconds(1))
            .withLatestFrom(reactor.state.map(\.isCheck))
            .map(Reactor.Action.check)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.resignButton.rx.throttleTap(.seconds(3))
            .map { _ in Reactor.Action.resign }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.isCheck)
            .distinctUntilChanged()
            .subscribe(with: self) { object, isCheck in
                object.checkBox.image = isCheck ? .init(.icon(.filled(.checkBox))) : .init(.icon(.outlined(.checkBox)))
                
                object.resignButton.isEnabled = isCheck
                object.resignButton.foregroundColor = isCheck ? .som.white : .som.gray600
                object.resignButton.backgroundColor = isCheck ? .som.p300 : .som.gray300
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isSuccess)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                guard let window = object.view.window else { return }
                
                let onboardingViewController = OnboardingViewController()
                onboardingViewController.reactor = reactor.reactorForOnboarding()
                onboardingViewController.modalTransitionStyle = .crossDissolve
                
                let navigationViewController = UINavigationController(rootViewController: onboardingViewController)
                window.rootViewController = navigationViewController
                
                object.navigationController?.viewControllers = []
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isError)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                let confirmAction = SOMDialogAction(
                    title: Text.confirmActionTitle,
                    style: .primary,
                    action: {
                        UIApplication.topViewController?.dismiss(animated: true) {
                            object.navigationPop()
                        }
                    }
                )
                
                SOMDialogViewController.show(
                    title: Text.dialogTitle,
                    message: Text.dialogMessge,
                    actions: [confirmAction]
                )
            }
            .disposed(by: self.disposeBag)
    }
}
