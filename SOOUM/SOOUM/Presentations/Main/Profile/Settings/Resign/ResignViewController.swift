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
        static let resignTitle: String = "탈퇴하기 전\n몇가지 안내가 있어요"
        static let firstResignGuide: String = "• 지금까지 작성한 카드와 정보들이 모두 삭제될 예정이에요"
        static let secondResignGuide: String = "• 재가입은 탈퇴 일자를 기준으로 일주일이후 가능해요"
        static let checkResignGuide: String = "위 안내사항을 모두 확인했습니다"
        static let resignButtonTitle: String = "탈퇴하기"
    }
    
    private let resignTitleLabel = UILabel().then {
        $0.text = Text.resignTitle
        $0.textColor = .som.gray800
        $0.textAlignment = .center
        $0.typography = .som.head2WithBold
        $0.numberOfLines = 0
    }
    
    private let firstResignGuideLabel = UILabel().then {
        $0.text = Text.firstResignGuide
        $0.textColor = .som.gray600
        $0.textAlignment = .left
        $0.typography = .som.body2WithRegular
        $0.numberOfLines = 0
    }
    
    private let secondResignGuideLabel = UILabel().then {
        $0.text = Text.secondResignGuide
        $0.textColor = .som.gray600
        $0.textAlignment = .left
        $0.typography = .som.body2WithRegular
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
    
    private let resignButton = UIButton().then {
        let typography = Typography.som.body1WithBold
        var attributes = typography.attributes
        attributes.updateValue(typography.font, forKey: .font)
        attributes.updateValue(UIColor.som.gray600, forKey: .foregroundColor)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init(
            Text.resignButtonTitle,
            attributes: AttributeContainer(attributes)
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            AttributeContainer(attributes)
        }
        $0.configuration = config
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
        
        self.view.addSubview(self.resignTitleLabel)
        self.resignTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(137)
            $0.centerX.equalToSuperview()
        }
        
        let resignGuideBackgroundView = UIView().then {
            $0.backgroundColor = .som.gray50
            $0.layer.cornerRadius = 13
            $0.clipsToBounds = true
        }
        self.view.addSubview(resignGuideBackgroundView)
        resignGuideBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.resignTitleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        resignGuideBackgroundView.addSubview(self.firstResignGuideLabel)
        self.firstResignGuideLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(19)
            $0.trailing.equalToSuperview().offset(-19)
        }
        resignGuideBackgroundView.addSubview(self.secondResignGuideLabel)
        self.secondResignGuideLabel.snp.makeConstraints {
            $0.top.equalTo(self.firstResignGuideLabel.snp.bottom)
            $0.bottom.equalToSuperview().offset(-20)
            $0.leading.equalToSuperview().offset(19)
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
                object.checkBox.image = .init(.icon(.outlined(isCheck ? .checkBoxOn : .checkBox)))
                
                let updateResignButtonConfigHandler: UIButton.ConfigurationUpdateHandler = { button in
                    var updateConfig = button.configuration
                    let updateTextAttributes = UIConfigurationTextAttributesTransformer { current in
                        var update = current
                        update.foregroundColor = isCheck ? .som.white : .som.gray600
                        return update
                    }
                    updateConfig?.titleTextAttributesTransformer = updateTextAttributes
                    button.configuration = updateConfig
                }
                
                object.resignButton.configurationUpdateHandler = updateResignButtonConfigHandler
                object.resignButton.setNeedsUpdateConfiguration()
                
                object.resignButton.isEnabled = isCheck
                object.resignButton.backgroundColor = isCheck ? .som.p300 : .som.gray300
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map((\.isSuccess))
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                DispatchQueue.main.async {
                    if let windowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window: UIWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                        
                        let viewController = OnboardingViewController()
                        window.rootViewController = UINavigationController(rootViewController: viewController)
                    }
                }
            }
            .disposed(by: self.disposeBag)
    }
}