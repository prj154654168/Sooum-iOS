//
//  BaseNavigationViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/21/24.
//

import UIKit

import RxCocoa
import RxSwift

import SnapKit
import Then


class BaseNavigationViewController: BaseViewController {

    let navigationBar = SOMNavigationBar()

    var backButton: UIButton {
        self.navigationBar.backButton
    }

    var backButtonDisposeBag = DisposeBag()

    private let navigationBarBackgroundView = UIView().then {
        $0.backgroundColor = .som.white
    }
    
    private let navigationBarBottomSeperator = UIView().then {
        $0.backgroundColor = .som.gray200
        $0.isHidden = true
    }

    private(set) var navigationPopWithBottomBarHidden: Bool = true
    private(set) var navigationPopGestureEnabled: Bool = true
    private(set) var navigationBarHeight: CGFloat = SOMNavigationBar.height

    var navigationBarColor: UIColor? {
        set {
            self.navigationBarBackgroundView.backgroundColor = newValue
        }
        get {
            self.navigationBarBackgroundView.backgroundColor
        }
    }

    var isNavigationBarHidden: Bool {
        set {
            self.additionalSafeAreaInsets.top = newValue ? 0 : self.navigationBarHeight
            self.navigationBar.isHidden = newValue
            self.navigationBarBackgroundView.isHidden = newValue
        }
        get {
            self.navigationBar.isHidden
        }
    }
    
    var hidesNavigationBarBottomSeperator: Bool {
        set {
            self.navigationBarBottomSeperator.isHidden = newValue
        }
        get {
            self.navigationBarBottomSeperator.isHidden
        }
    }

    override func viewDidLoad() {

        self.isNavigationBarHidden = false
        /// 네비게이션 바가 isHidden 에 따라, safeAreaInsets.top을 조절 (isHidden == false, 네비게이션 바 아래쪽으로 뷰를 붙이기 위해)
        self.navigationBar.rx.observe(\.isHidden)
            .distinctUntilChanged()
            .subscribe(with: self) { object, isHidden in
                object.additionalSafeAreaInsets.top = isHidden ? 0 : object.navigationBarHeight
            }
            .disposed(by: self.disposeBag)

        super.viewDidLoad()

        // 최상단에 적용되어야 하므로 setupConstraints 뒤인 이 곳에 위치함
        self.view.addSubview(self.navigationBarBackgroundView)
        self.navigationBarBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top)
            $0.centerX.width.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }

        self.view.addSubview(self.navigationBar)
        self.navigationBar.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.navigationBarHeight)
        }
        
        self.view.addSubview(self.navigationBarBottomSeperator)
        self.navigationBarBottomSeperator.snp.makeConstraints {
            $0.bottom.equalTo(self.navigationBar.snp.bottom)
            $0.leading.equalTo(self.navigationBar.snp.leading)
            $0.trailing.equalTo(self.navigationBar.snp.trailing)
            $0.height.equalTo(1.4)
        }
        // 로딩 뷰는 항상 최상단에 표시
        self.view.bringSubviewToFront(self.loadingIndicatorView)
    }

    override func bind() {
        super.bind()

        self.backButton.rx.tap
            .subscribe(with: self) { object, _ in
                object.navigationPop(
                    animated: true,
                    bottomBarHidden: object.navigationPopWithBottomBarHidden
                )
            }
            .disposed(by: self.backButtonDisposeBag)
    }

    override func setupNaviBar() {
        super.setupNaviBar()

        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.isNavigationBarHidden = true

        self.navigationItem.setLeftBarButton(nil, animated: false)
        self.navigationItem.hidesBackButton = true
    }

    override func viewWillAppear(_ animated: Bool) {
        // setupNaviBar() 가 viewWillAppear(_:)에서 호출되지 않게 함
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = self.navigationPopGestureEnabled
        
        // 순환참조가 발생할 경우 약한 참조인 delegate가 nil이 되기 때문에,
        // 네비게이션바 설정이 무시될 수 있습니다. 이를 방어하기 위해 네비게이션바를 설정합니다.
        if self.navigationController?.delegate == nil {
            let isFirstViewController = self.navigationController?.viewControllers.first == self
            self.navigationBar.hidesBackButton = isFirstViewController
            self.setupNaviBar()
        }
    }
}


extension BaseNavigationViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.navigationPopGestureEnabled
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return self.navigationPopGestureEnabled
    }
}

extension Reactive where Base: BaseNavigationViewController {

    var navigationBarColor: Binder<UIColor?> {
        return Binder(self.base) { view, value in
            view.navigationBarColor = value
        }
    }
}

extension BaseNavigationViewController: UINavigationControllerDelegate {

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        self.navigationBar.hidesBackButton = navigationController.viewControllers.first == self
        if viewController == self {
            self.setupNaviBar()
        }
    }
}
