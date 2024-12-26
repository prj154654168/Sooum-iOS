//
//  NotificationTabBarController.swift
//  SOOUM
//
//  Created by 오현식 on 12/20/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


class NotificationTabBarController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "덧글 히스토리"
        
        static let tabTotalTitle: String = "전체"
        static let tabCommentTitle: String = "답카드"
        static let tabLikeTitle: String = "공감"
    }
    
    
    // MARK: Views
    
    private lazy var headerTabBar = SOMSwipeTabBar(alignment: .fill).then {
        $0.inset = .zero
        $0.spacing = 0
        $0.seperatorHeight = 1.4
        $0.seperatorColor = .som.gray300
        $0.items = [Text.tabTotalTitle, Text.tabCommentTitle, Text.tabLikeTitle]
        
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
    
    
    // MARK: Override variables
    
    override var navigationBarHeight: CGFloat {
        46
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.headerTabBar)
        self.headerTabBar.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(SOMSwipeTabBar.Height.notification)
        }
        
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(self.headerTabBar.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: NotificationTabBarReactor) {
        
        let notificationTotalViewController = NotificationViewController()
        notificationTotalViewController.reactor = reactor.reactorForTotal()
        
        self.pages.append(notificationTotalViewController)
        
        let notificationCommentViewController = NotificationViewController()
        notificationCommentViewController.reactor = reactor.reactorForComment()
        
        self.pages.append(notificationCommentViewController)
        
        let notificationLikeViewController = NotificationViewController()
        notificationLikeViewController.reactor = reactor.reactorForLike()
        
        self.pages.append(notificationLikeViewController)
        
        self.currentPage = 0
        self.pageViewController.setViewControllers(
            [self.pages[0]],
            direction: .forward,
            animated: true,
            completion: nil
        )
        
        // 각 뷰컨트롤러의 willPushCardId 구독
        Observable.merge(
            notificationTotalViewController.willPushCardId.asObservable(),
            notificationCommentViewController.willPushCardId.asObservable(),
            notificationLikeViewController.willPushCardId.asObservable()
        )
        .subscribe(with: self) { object, willPushCardId in
            
            let detailViewController = DetailViewController()
            detailViewController.reactor = reactor.reactorForDetail(willPushCardId)
            object.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
        }
        .disposed(by: self.disposeBag)
    }
}

extension NotificationTabBarController: SOMSwipeTabBarDelegate {
    
    func tabBar(_ tabBar: SOMSwipeTabBar, shouldSelectTabAt index: Int) -> Bool {
        return true
    }
    
    func tabBar(_ tabBar: SOMSwipeTabBar, didSelectTabAt index: Int) {
        
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

extension NotificationTabBarController: UIPageViewControllerDataSource {
    
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
        
        return self.pages[currentIndex + 1]
    }
}

extension NotificationTabBarController: UIPageViewControllerDelegate {
    
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
            self.headerTabBar.didSelectTabBarItem(self.currentPage)
        }
    }
}
