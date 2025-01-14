//
//  MainHomeTabBarController.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


class MainHomeTabBarController: BaseNavigationViewController, View {
    
    enum Text {
        static let tabLatestTitle: String = "최신순"
        static let tabPopularityTitle: String = "인기순"
        static let tabDistanceTitle: String = "거리순"
        
        static let dialogTitle: String = "위치 정보 사용 설정"
        static let dialogSubTitle: String = "위치 확인을 위해 권한 설정이 필요해요"
    }
    
    
    // MARK: Set navigationBar Items
    
    private let logo = UIImageView().then {
        $0.image = .init(.logo)
        $0.tintColor = .som.p300
        $0.contentMode = .scaleAspectFit
    }
    
    private let rightAlamButton = SOMButton().then {
        $0.image = .init(.icon(.outlined(.alarm)))
        $0.foregroundColor = .som.gray700
    }
    
    private let dotWithoutReadView = UIView().then {
        $0.backgroundColor = .som.red
        $0.layer.cornerRadius = 6 * 0.5
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    
    // MARK: Views
    
    private let headerContainer = UIStackView().then {
        $0.axis = .vertical
    }
    
    private lazy var headerTapBar = SOMSwipeTabBar(alignment: .left).then {
        $0.items = [Text.tabLatestTitle, Text.tabPopularityTitle, Text.tabDistanceTitle]
        
        $0.delegate = self
    }
    
    private lazy var headerLocationFilter = SOMLocationFilter().then {
        $0.delegate = self
    }
    
    private lazy var pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    ).then {
        $0.dataSource = self
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    private var pages = [UIViewController]()
    private var currentPage: Int = 0
    
    private var headerContainerHeight: CGFloat = SOMSwipeTabBar.Height.mainHome
    
    private var animator: UIViewPropertyAnimator?
    
    
    // MARK: Constraints
    
    private var headerLocationFilterHeightConstraint: Constraint?
    private var pageViewTopConstraint: Constraint?
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.titleView = self.logo
        self.navigationBar.titlePosition = .left
        
        self.navigationBar.hidesBackButton = true
        
        self.rightAlamButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        (self.rightAlamButton.imageView ?? self.rightAlamButton).addSubview(self.dotWithoutReadView)
        self.dotWithoutReadView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview().offset(-3)
            $0.size.equalTo(6)
        }
        self.navigationBar.setRightButtons([self.rightAlamButton])
    }
    
    override func bind() {
        super.bind()
        
        // 탭바 표시
        self.rx.viewWillAppear
            .subscribe(with: self) { object, _ in
                object.hidesBottomBarWhenPushed = false
            }
            .disposed(by: self.disposeBag)
        
        // 알림 화면으로 전환
        self.rightAlamButton.rx.tap
            .subscribe(with: self) { object, _ in
                let notificatinoTabBarController = NotificationTabBarController()
                notificatinoTabBarController.reactor = object.reactor?.reactorForNoti()
                object.navigationPush(notificatinoTabBarController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        // 유저 정보 모두 제거 후 온보딩 화면으로 전환
        #if DEVELOP
        logo.rx.longPressGesture()
            .when(.began)
            .subscribe(with: self) { object, _ in
                AuthKeyChain.shared.delete(.deviceId)
                AuthKeyChain.shared.delete(.refreshToken)
                AuthKeyChain.shared.delete(.accessToken)
                
                DispatchQueue.main.async {
                    if let windowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window: UIWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                        
                        let viewController = OnboardingViewController()
                        window.rootViewController = UINavigationController(rootViewController: viewController)
                    }
                }
            }
            .disposed(by: self.disposeBag)
        #endif
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.headerContainer)
        self.headerContainer.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        self.headerContainer.addArrangedSubview(self.headerTapBar)
        self.headerTapBar.snp.makeConstraints {
            $0.height.equalTo(SOMSwipeTabBar.Height.mainHome)
        }
        self.headerContainer.addArrangedSubview(self.headerLocationFilter)
        self.headerLocationFilter.snp.makeConstraints {
            self.headerLocationFilterHeightConstraint = $0.height.equalTo(0).priority(.high).constraint
        }
        
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.view.snp.makeConstraints {
            self.pageViewTopConstraint = $0.top.equalTo(self.headerContainer.snp.bottom)
                .priority(.high)
                .constraint
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: MainHomeTabBarReactor) {
        
        let mainHomeLatestViewController = MainHomeLatestViewController()
        mainHomeLatestViewController.reactor = reactor.reactorForLatest()
        
        self.pages.append(mainHomeLatestViewController)
        
        let mainHomePopularViewController = MainHomePopularViewController()
        mainHomePopularViewController.reactor = reactor.reactorForPopular()
        
        self.pages.append(mainHomePopularViewController)
        
        let mainHomeDistanceViewController = MainHomeDistanceViewController()
        mainHomeDistanceViewController.reactor = reactor.reactorForDistance()
        
        self.pages.append(mainHomeDistanceViewController)
        
        self.currentPage = 0
        self.pageViewController.setViewControllers(
            [self.pages[0]],
            direction: .forward,
            animated: false,
            completion: nil
        )
        
        // 각 뷰컨트롤러의 hidesHeaderContainer 구독
        Observable.merge(
            mainHomeLatestViewController.hidesHeaderContainer.distinctUntilChanged().asObservable(),
            mainHomePopularViewController.hidesHeaderContainer.distinctUntilChanged().asObservable(),
            mainHomeDistanceViewController.hidesHeaderContainer.distinctUntilChanged().asObservable()
        )
        .observe(on: MainScheduler.instance)
        .subscribe(with: self) { object, hidesHeaderContainer in
            
            // 애니메이터가 이미 실행 중이라면 취소하고 새 애니메이션 시작
            if object.animator?.state == .active {
                
                object.animator?.stopAnimation(false)
                object.animator?.finishAnimation(at: .end)
            }
            
            object.headerContainer.isHidden = hidesHeaderContainer
            
            object.pageViewTopConstraint?.deactivate()
            object.pageViewController.view.snp.makeConstraints {
                let top = hidesHeaderContainer ? object.view.safeAreaLayoutGuide.snp.top : object.headerContainer.snp.bottom
                object.pageViewTopConstraint = $0.top.equalTo(top).priority(.high).constraint
            }
            
            // 애니메이션 추가
            object.animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut)
            object.animator?.addAnimations {
                
                object.view.layoutIfNeeded()
            }
            // 새 애니메이션 시작
            object.animator?.startAnimation()
            // 애니메이션이 끝난 후 animator 초기화
            object.animator?.addCompletion { position in
                
                if position == .end { object.animator = nil }
            }
        }
        .disposed(by: self.disposeBag)
        
        // 각 뷰컨트롤러의 willPushCardId 구독
        Observable.merge(
            mainHomeLatestViewController.willPushCardId.asObservable(),
            mainHomePopularViewController.willPushCardId.asObservable(),
            mainHomeDistanceViewController.willPushCardId.asObservable()
        )
        .subscribe(with: self) { object, willPushCardId in
            
            let detailViewController = DetailViewController()
            detailViewController.reactor = reactor.reactorForDetail(willPushCardId)
            object.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
        }
        .disposed(by: self.disposeBag)
        
        // Action
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.notisWithoutRead }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.noNotisWithoutRead)
            .bind(to: self.dotWithoutReadView.rx.isHidden)
            .disposed(by: self.disposeBag)
    }
}

extension MainHomeTabBarController: SOMSwipeTabBarDelegate {
    
    func tabBar(_ tabBar: SOMSwipeTabBar, shouldSelectTabAt index: Int) -> Bool {
        
        if index == 2, self.reactor?.locationManager.checkLocationAuthStatus() == .denied {
            
            SOMDialogViewController.show(
                title: Text.dialogTitle,
                subTitle: Text.dialogSubTitle,
                leftAction: .init(
                    mode: .cancel,
                    handler: { UIApplication.topViewController?.dismiss(animated: true) }
                ),
                rightAction: .init(
                    mode: .setting,
                    handler: {
                        let application = UIApplication.shared
                        let openSettingsURLString: String = UIApplication.openSettingsURLString
                        if let settingsURL = URL(string: openSettingsURLString),
                           application.canOpenURL(settingsURL) {
                            application.open(settingsURL)
                        }
                        
                        UIApplication.topViewController?.dismiss(animated: true)
                    }
                )
            )
            return false
        }
        
        return true
    }
    
    func tabBar(_ tabBar: SOMSwipeTabBar, didSelectTabAt index: Int) {
        
        let hidesLocationFilter = index != 2
        
        self.headerLocationFilterHeightConstraint?.deactivate()
        self.headerLocationFilter.snp.makeConstraints {
            let height = hidesLocationFilter ? 0 : SOMLocationFilter.height
            self.headerLocationFilterHeightConstraint = $0.height.equalTo(height).priority(.high).constraint
        }
        
        UIView.performWithoutAnimation {
            self.view.layoutIfNeeded()
        }
        
        if self.currentPage != index {
            
            self.currentPage = index
            self.pageViewController.setViewControllers(
                [self.pages[index]],
                direction: tabBar.previousIndex <= index ? .forward : .reverse,
                animated: true,
                completion: nil
            )
        }
    }
}

extension MainHomeTabBarController: SOMLocationFilterDelegate {
    
    func filter(_ filter: SOMLocationFilter, didSelectDistanceAt distance: SOMLocationFilter.Distance) {
        guard filter.prevDistance != distance,
              let mainHomeDistanceViewController = self.pages[self.currentPage] as? MainHomeDistanceViewController
        else { return }
        
        mainHomeDistanceViewController.reactor?.action.onNext(.distanceFilter(distance.rawValue))
    }
}

extension MainHomeTabBarController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = self.pages.firstIndex(of: viewController),
              currentIndex > 0
        else { return nil }
        
        return self.pages[currentIndex - 1]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = self.pages.firstIndex(of: viewController),
              currentIndex < self.pages.count - 1
        else { return nil }
        
        if self.currentPage + 1 == 2, self.reactor?.locationManager.locationAuthStatus == .denied {
            
            SOMDialogViewController.show(
                title: Text.dialogTitle,
                subTitle: Text.dialogSubTitle,
                leftAction: .init(
                    mode: .cancel,
                    handler: { UIApplication.topViewController?.dismiss(animated: true) }
                ),
                rightAction: .init(
                    mode: .setting,
                    handler: {
                        let application = UIApplication.shared
                        let openSettingsURLString: String = UIApplication.openSettingsURLString
                        if let settingsURL = URL(string: openSettingsURLString),
                           application.canOpenURL(settingsURL) {
                            application.open(settingsURL)
                        }
                        
                        UIApplication.topViewController?.dismiss(animated: true)
                    }
                )
            )
            
            return nil
        } else {
            
            return self.pages[currentIndex + 1]
        }
    }
}

extension MainHomeTabBarController: UIPageViewControllerDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        self.currentPage = self.pages.firstIndex(of: pendingViewControllers[0]) ?? 0
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed {
            self.headerTapBar.didSelectTabBarItem(self.currentPage)
        }
    }
}
